provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "foo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tf-test"
  }
}

resource "aws_subnet" "foo" {
  vpc_id            = aws_vpc.foo.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-test"
  }
}

resource "aws_subnet" "foo_2" {
  vpc_id            = aws_vpc.foo.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "tf-test"
  }
}

resource "aws_route_table_association" "public-rtb-assoc_1" {
  route_table_id = aws_route_table.public-rtb.id
  subnet_id = aws_subnet.foo.id
}

resource "aws_route_table_association" "public-rtb-assoc_2" {
  route_table_id = aws_route_table.public-rtb.id
  subnet_id = aws_subnet.foo_2.id
}

resource "aws_security_group" "nondefault" {
  vpc_id = aws_vpc.foo.id

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
  vpc_id = aws_vpc.foo.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.foo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-rtb"
  }
}

resource "aws_elasticache_subnet_group" "bar" {
  name       = "tf-test-cache-subnet"
  subnet_ids = [aws_subnet.foo.id, aws_subnet.foo_2.id]
}

resource "aws_elasticache_replication_group" "cloudrail" {
  automatic_failover_enabled    = true
  availability_zones            = ["us-east-1a", "us-east-1b"]
  replication_group_id          = "tf-rep-group-1-encrypted"
  replication_group_description = "Encrypted"
  node_type                     = "cache.m4.large"
  number_cache_clusters         = 2
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  subnet_group_name = aws_elasticache_subnet_group.bar.name
  security_group_ids = [aws_security_group.nondefault.id]
}
