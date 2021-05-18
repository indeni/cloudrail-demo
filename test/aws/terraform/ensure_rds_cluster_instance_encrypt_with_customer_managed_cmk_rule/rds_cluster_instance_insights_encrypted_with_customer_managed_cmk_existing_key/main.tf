provider "aws" {
  region = "us-east-1"
}

data "aws_kms_key" "by_alias" {
  key_id = "alias/test-rds"
}

resource "aws_rds_cluster" "test" {
  cluster_identifier  = "cloudrail-test-encrypted"
  engine              = "aurora-mysql"
  engine_version      = "5.7.mysql_aurora.2.04.2"
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_name       = "cloudrail"
  master_username     = "administrator"
  master_password     = "cloudrail-TEST-password"
  skip_final_snapshot = true
  storage_encrypted   = true
}

resource "aws_rds_cluster_instance" "test" {
  count                           = 2
  identifier                      = "aurora-cluster-demo-${count.index}"
  cluster_identifier              = aws_rds_cluster.test.id
  engine                          = aws_rds_cluster.test.engine
  engine_version                  = aws_rds_cluster.test.engine_version
  instance_class                  = "db.r4.large"
  performance_insights_enabled    = true
  performance_insights_kms_key_id = data.aws_kms_key.by_alias.arn
}
