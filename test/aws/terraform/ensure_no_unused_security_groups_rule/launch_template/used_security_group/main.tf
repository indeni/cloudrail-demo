provider "aws" {
  region = "us-east-1"
}

locals {
  test_name = "test http_tokens launch template - required"
}

resource "aws_launch_template" "launch_template_test" {
  name = "launch_template_test"

  image_id = "ami-022f8e8ca7e5665d7"

  instance_type = "t2.micro"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  network_interfaces {
    associate_public_ip_address = true
  }

  placement {
    availability_zone = "us-east-2a"
  }

  vpc_security_group_ids = [aws_security_group.allow-http.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "test"
    }
  }
}

resource "aws_security_group" "allow-http" {
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
