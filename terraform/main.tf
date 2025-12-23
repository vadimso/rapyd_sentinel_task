terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Single VPC for both environments (avoids VPC limit)
module "vpc_main" {
  source = "./modules/vpc"

  name               = "vpc-rapyd-sentinel-poc"
  cidr_block         = "10.0.0.0/16"
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = false  # Disable to avoid IGW limit
  enable_s3_endpoint = true
  region             = var.region

  tags = {
    Environment = "production"
    Project     = "rapyd-sentinel"
  }
}

# Gateway EKS Cluster (uses first 2 subnets)
module "eks_gateway" {
  source = "./modules/eks"

  cluster_name        = "eks-gateway-poc"
  vpc_id              = module.vpc_main.vpc_id
  subnet_ids          = slice(module.vpc_main.private_subnets, 0, 2)  # First 2 subnets
  kubernetes_version  = "1.27"
  desired_nodes       = 2
  min_nodes           = 1
  max_nodes           = 3
  instance_type       = "t3.medium"
  peering_cidr_blocks = []  # No peering needed in single VPC

  tags = {
    Environment = "gateway"
    Project     = "rapyd-sentinel"
  }
}

# Backend EKS Cluster (uses last 2 subnets)
module "eks_backend" {
  source = "./modules/eks"

  cluster_name        = "eks-backend-poc"
  vpc_id              = module.vpc_main.vpc_id
  subnet_ids          = slice(module.vpc_main.private_subnets, 2, 4)  # Last 2 subnets
  kubernetes_version  = "1.27"
  desired_nodes       = 2
  min_nodes           = 1
  max_nodes           = 3
  instance_type       = "t3.medium"
  peering_cidr_blocks = []  # No peering needed in single VPC

  tags = {
    Environment = "backend"
    Project     = "rapyd-sentinel"
  }
}
