provider "aws" {
  region = "us-east-1"
}

resource "aws_api_gateway_rest_api" "my-api-gateway" {
  name = "my-api-gateway"

  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_resource" "my-api-gateway-resource" {
  path_part   = "v1"
  parent_id   = aws_api_gateway_rest_api.my-api-gateway.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.my-api-gateway.id
}

resource "aws_api_gateway_method" "my-api-gateway-method" {
  rest_api_id   = aws_api_gateway_rest_api.my-api-gateway.id
  resource_id   = aws_api_gateway_resource.my-api-gateway-resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "my-lambda-func-integration" {
  rest_api_id             = aws_api_gateway_rest_api.my-api-gateway.id
  resource_id             = aws_api_gateway_resource.my-api-gateway-resource.id
  http_method             = aws_api_gateway_method.my-api-gateway-method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.my-lambda-func.invoke_arn
}

# Lambda
resource "aws_lambda_permission" "my-lambda-func-permissions" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my-lambda-func.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:us-east-1:111111111111:/${aws_api_gateway_rest_api.my-api-gateway.id}/*/*"
}

resource "aws_lambda_function" "my-lambda-func" {
  function_name = "my-lambda-func"
  role          = aws_iam_role.my-lambda-func-role.arn
  handler       = "lambda.lambda_handler"
  runtime       = "python2.7"
  s3_bucket      = "my-lambda-func-repo"
  s3_key = "my-lambda-func-1.0.zip"
}

# IAM
resource "aws_iam_role" "my-lambda-func-role" {
  name = "my-lambda-func-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "lambda-role-execution-policy" {
  name        = "lambda-role-execution-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.my-bucket.bucket}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.my-lambda-func-role.name
  policy_arn = aws_iam_policy.lambda-role-execution-policy.arn
}

resource "aws_s3_bucket" "my-bucket" {
  bucket = "my-bucket"
}

resource "aws_s3_bucket_policy" "my-bucket-policy" {
  bucket = aws_s3_bucket.my-bucket.id

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"PublicRead",
      "Effect":"Allow",
      "Principal": {"Service": "apigateway.amazonaws.com"},
      "Action": "s3:*",
      "Resource":["arn:aws:s3:::${aws_s3_bucket.my-bucket.bucket}"]
    }
  ]
}
POLICY
}