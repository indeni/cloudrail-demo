provider "aws" {
  region = "us-east-1"
}

resource "aws_autoscaling_group" "test-autoscaling-group" {
  name                      = "test-autoscaling-group"
  max_size                  = 5
  min_size                  = 1
  launch_configuration = aws_launch_configuration.test-asg-launch-conf.name
  vpc_zone_identifier = [aws_subnet.private-subnet-1.id]
}

resource "aws_launch_configuration" "test-asg-launch-conf" {
  image_id      = data.aws_ami.ubuntu-ami.id
  instance_type = "t2.micro"
  spot_price    = "0.001"
  associate_public_ip_address = true
  security_groups = [aws_security_group.allow-http.id]

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "ubuntu-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.16.100.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
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
