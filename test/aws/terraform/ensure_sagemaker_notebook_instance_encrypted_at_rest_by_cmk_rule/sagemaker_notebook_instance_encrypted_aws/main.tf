provider "aws" {
  region = "us-east-1"
}

data "aws_iam_policy" "AmazonSageMakerFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role" "test" {
  name               = "test_sagemaker_role"
  assume_role_policy = <<-EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "sagemaker.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.test.name
  policy_arn = data.aws_iam_policy.AmazonSageMakerFullAccess.arn
}

resource "aws_sagemaker_notebook_instance" "test" {
  name          = "my-notebook-instance"
  role_arn      = aws_iam_role.test.arn
  instance_type = "ml.t2.medium"
}
