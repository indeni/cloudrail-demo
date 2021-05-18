provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "nondefault" {
  cidr_block = "10.1.1.0/24"
}

resource "aws_security_group" "nondefault" {
  vpc_id = aws_vpc.nondefault.id

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

resource "aws_subnet" "nondefault_1" {
  vpc_id = aws_vpc.nondefault.id
  cidr_block = "10.1.1.128/25"
  availability_zone = "us-east-1c"
}

resource "aws_subnet" "nondefault_2" {
  vpc_id = aws_vpc.nondefault.id
  cidr_block = "10.1.1.0/25"
  availability_zone = "us-east-1d"
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

resource "aws_route_table_association" "public-rtb-assoc_1" {
  route_table_id = aws_route_table.public-rtb.id
  subnet_id = aws_subnet.nondefault_1.id
}

resource "aws_route_table_association" "public-rtb-assoc_2" {
  route_table_id = aws_route_table.public-rtb.id
  subnet_id = aws_subnet.nondefault_2.id
}


data "aws_workspaces_bundle" "value_windows_10" {
  bundle_id = "wsb-bh8rsxt14"
}

data "aws_iam_policy_document" "workspaces" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["workspaces.amazonaws.com"]
    }
  }
}

resource "aws_directory_service_directory" "test" {
  name     = "corp.notexample.com"
  password = "SuperSecretPassw0rd"
  size     = "Small"

  vpc_settings {
    vpc_id = aws_vpc.nondefault.id

    subnet_ids = [
      aws_subnet.nondefault_1.id,
      aws_subnet.nondefault_2.id
    ]
  }
}

resource "aws_workspaces_directory" "test" {
  directory_id = aws_directory_service_directory.test.id

  subnet_ids = [
    aws_subnet.nondefault_1.id,
    aws_subnet.nondefault_2.id
  ]

  depends_on = [
    aws_iam_role_policy_attachment.workspaces_default_service_access,
    aws_iam_role_policy_attachment.workspaces_default_self_service_access
  ]
}

resource "aws_iam_role" "workspaces_default" {
  name               = "workspaces_DefaultRole"
  assume_role_policy = data.aws_iam_policy_document.workspaces.json
}

resource "aws_iam_role_policy_attachment" "workspaces_default_service_access" {
  role       = aws_iam_role.workspaces_default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesServiceAccess"
}

resource "aws_iam_role_policy_attachment" "workspaces_default_self_service_access" {
  role       = aws_iam_role.workspaces_default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesSelfServiceAccess"
}

resource "aws_kms_key" "test" {
  description             = "KMS key for Workspaces - creating"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "test" {
  name          = "alias/test-workspace"
  target_key_id = aws_kms_key.test.key_id
}

resource "aws_workspaces_workspace" "test" {
  directory_id = aws_workspaces_directory.test.id
  bundle_id    = data.aws_workspaces_bundle.value_windows_10.id
  user_name    = "Administrator"

  user_volume_encryption_enabled = true
  volume_encryption_key          = aws_kms_alias.test.arn

  workspace_properties {
    compute_type_name                         = "VALUE"
    user_volume_size_gib                      = 10
    root_volume_size_gib                      = 80
    running_mode                              = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
  }
}

resource "aws_security_group" "unused" {
  vpc_id     = aws_vpc.nondefault.id
  name = "Unused security group"

  ingress {
    from_port = 53
    protocol = "UDP"
    to_port = 53
    cidr_blocks = ["0.0.0.0/0"]
  }
}