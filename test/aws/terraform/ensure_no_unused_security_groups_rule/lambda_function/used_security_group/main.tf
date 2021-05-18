provider "aws" {
  region = "us-east-1"
}

locals {
  lambda_name = "cloudrail_test_lambda"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
    role       = aws_iam_role.iam_for_lambda.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 0
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "${path.module}/Archive.zip"
  function_name = local.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.handler"
  runtime       = "python3.8"

  vpc_config {
    security_group_ids = [aws_security_group.allow-http.id]
    subnet_ids = [aws_subnet.private-subnet.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.log_group,
  ]
}

resource "aws_vpc" "main" {
  cidr_block = "192.168.100.0/24"
}


resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.100.128/25"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_security_group" "allow-http" {
  vpc_id     = aws_vpc.main.id
  description = "allow http"
  ingress {
    from_port = 80
    protocol = "TCP"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
