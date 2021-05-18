provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "nondefault" {
  cidr_block = "10.1.1.0/24"
}

resource "aws_security_group" "nondefault" {
  vpc_id = aws_vpc.nondefault.id
}

resource "aws_subnet" "nondefault_1" {
  vpc_id = aws_vpc.nondefault.id
  cidr_block = "10.1.1.128/25"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "nondefault_2" {
  vpc_id = aws_vpc.nondefault.id
  cidr_block = "10.1.1.0/25"
  availability_zone = "us-east-1b"
}

resource "aws_db_subnet_group" nondefault {
  name = "nondefault"
  subnet_ids = [aws_subnet.nondefault_1.id, aws_subnet.nondefault_2.id]

}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
  description      = "Allows Amazon ES to manage AWS resources for a domain on your behalf."
}

resource "aws_elasticsearch_domain" "test" {
  domain_name = "test"

  vpc_options {
    subnet_ids = [aws_subnet.nondefault_1.id]
    security_group_ids = [aws_security_group.nondefault.id]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }
}
