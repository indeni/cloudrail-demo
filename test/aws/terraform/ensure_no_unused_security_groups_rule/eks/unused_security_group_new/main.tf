provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name = "test"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

data "aws_eks_cluster" "cluster" {
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "my-cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "v13.0.0"
  cluster_name    = "my-cluster"
  cluster_version = "1.16"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 5
    }
  ]
}

resource "aws_security_group" "unused" {
  vpc_id = module.vpc.vpc_id
  name = "Unused security group"

  ingress {
    from_port = 53
    protocol = "UDP"
    to_port = 53
    cidr_blocks = ["0.0.0.0/0"]
  }
}