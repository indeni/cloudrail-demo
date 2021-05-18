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
  direct_internet_access = "Disabled"
  subnet_id = aws_subnet.nondefault.id
  security_groups = [aws_security_group.nondefault.id]
}

resource "aws_vpc" "nondefault" {
  cidr_block = "10.1.1.0/24"
}

resource "aws_security_group" "nondefault" {
  vpc_id = aws_vpc.nondefault.id

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_subnet" "nondefault" {
  vpc_id = aws_vpc.nondefault.id
  cidr_block = "10.1.1.128/25"
  availability_zone = "us-east-1a"
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.nondefault.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.nondefault.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-rtb"
  }
}
