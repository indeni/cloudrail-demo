provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "over-privilege-role" {
  name = "over-privilege-role"

  assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "AWS": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        },
        {
          "Action": "sts:AssumeRole",
          "Principal": "*",
          "Effect": "Allow",
          "Sid": "",
          "Condition" : {
            "StringEquals" : { "aws:PrincipalArn" : "arn:aws:iam::111111111111:role/groke" }
          }
        }
      ]
    }
EOF
}
