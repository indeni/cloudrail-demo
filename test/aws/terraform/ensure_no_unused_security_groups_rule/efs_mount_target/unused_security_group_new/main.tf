provider "aws" {
  region = "us-east-1"
}

resource "aws_efs_file_system" "cloudrail" {
  creation_token = "cloudrail-encrypted"
  encrypted      = true

  tags = {
    Name = "Encrypted"
  }
}

resource "aws_efs_mount_target" "alpha" {
  file_system_id = aws_efs_file_system.cloudrail.id
  subnet_id      = aws_subnet.alpha_subnet.id
  security_groups = [aws_security_group.nondefault.id]
}

resource "aws_vpc" "main" {
  cidr_block = "192.168.100.0/24"
}

resource "aws_subnet" "alpha_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.100.0/25"

}

resource "aws_security_group" "nondefault" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-rtb"
  }
}

resource "aws_route_table_association" "public-rtb-assoc_1" {
  route_table_id = aws_route_table.public-rtb.id
  subnet_id = aws_subnet.alpha_subnet.id
}


resource "aws_security_group" "unused" {
  vpc_id = aws_vpc.main.id
  name = "Unused security group"

  ingress {
    from_port = 53
    protocol = "UDP"
    to_port = 53
    cidr_blocks = ["0.0.0.0/0"]
  }
}