
provider "aws" {
  region = "us-east-1"
}

module "public-vpc" {
  source = "../../../../terraform-tests-modules/public-vpc"
  all-subnets-azs = ["a"]
}

resource "aws_vpc_endpoint" "ec2-vpc-endpoint" {
  vpc_id            = module.public-vpc.vpc-id
  service_name      = "com.amazonaws.${module.public-vpc.vpc-region}.ec2"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = module.public-vpc.subnets-ids
  security_group_ids = [module.public-vpc.public-internet-sg-id]
}
