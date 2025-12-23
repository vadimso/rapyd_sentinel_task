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

# Gateway VPC
module "vpc_gateway" {
  source = "./modules/vpc"

  name               = "vpc-gateway-poc"
  cidr_block         = "10.0.0.0/16"
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_nat_gateway = false  # Disable to avoid IGW limit
  enable_s3_endpoint = true
  region             = var.region

  tags = {
    Environment = "gateway"
    Project     = "rapyd-sentinel"
  }
}

# Backend VPC
module "vpc_backend" {
  source = "./modules/vpc"

  name               = "vpc-backend-poc"
  cidr_block         = "10.1.0.0/16"
  private_subnets    = ["10.1.1.0/24", "10.1.2.0/24"]
  enable_nat_gateway = false  # Disable to avoid IGW limit
  enable_s3_endpoint = true
  region             = var.region

  tags = {
    Environment = "backend"
    Project     = "rapyd-sentinel"
  }
}

# VPC Peering
resource "aws_vpc_peering_connection" "gateway_backend" {
  vpc_id      = module.vpc_gateway.vpc_id
  peer_vpc_id = module.vpc_backend.vpc_id

  tags = {
    Name    = "gateway-backend-peering"
    Project = "rapyd-sentinel"
  }
}

# Accept the peering connection
resource "aws_vpc_peering_connection_accepter" "gateway_backend" {
  vpc_peering_connection_id = aws_vpc_peering_connection.gateway_backend.id
  auto_accept               = true

  tags = {
    Name    = "gateway-backend-peering"
    Project = "rapyd-sentinel"
  }
}

# Route table entries for gateway VPC
resource "aws_route" "gateway_to_backend" {
  route_table_id            = module.vpc_gateway.private_subnets[0] == module.vpc_gateway.private_subnets[0] ? aws_route_table.gateway_private[0].id : aws_route_table.gateway_private[0].id
  destination_cidr_block    = module.vpc_backend.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.gateway_backend.id
}

# Route table entries for backend VPC
resource "aws_route" "backend_to_gateway" {
  route_table_id            = module.vpc_backend.private_subnets[0] == module.vpc_backend.private_subnets[0] ? aws_route_table.backend_private[0].id : aws_route_table.backend_private[0].id
  destination_cidr_block    = module.vpc_gateway.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.gateway_backend.id
}

# Gateway EKS Cluster
module "eks_gateway" {
  source = "./modules/eks"

  cluster_name        = "eks-gateway-poc"
  vpc_id              = module.vpc_gateway.vpc_id
  subnet_ids          = module.vpc_gateway.private_subnets
  kubernetes_version  = "1.27"
  desired_nodes       = 2
  instance_type       = "t3.medium"
  peering_cidr_blocks = [module.vpc_backend.vpc_cidr_block]

  tags = {
    Environment = "gateway"
    Project     = "rapyd-sentinel"
  }
}

# Backend EKS Cluster
module "eks_backend" {
  source = "./modules/eks"

  cluster_name        = "eks-backend-poc"
  vpc_id              = module.vpc_backend.vpc_id
  subnet_ids          = module.vpc_backend.private_subnets
  kubernetes_version  = "1.27"
  desired_nodes       = 2
  instance_type       = "t3.medium"
  peering_cidr_blocks = [module.vpc_gateway.vpc_cidr_block]

  tags = {
    Environment = "backend"
    Project     = "rapyd-sentinel"
  }
}

# Additional route tables for peering (simplified approach)
resource "aws_route_table" "gateway_private" {
  count  = length(module.vpc_gateway.private_subnets)
  vpc_id = module.vpc_gateway.vpc_id

  tags = {
    Name    = "gateway-private-${count.index}"
    Project = "rapyd-sentinel"
  }
}

resource "aws_route_table" "backend_private" {
  count  = length(module.vpc_backend.private_subnets)
  vpc_id = module.vpc_backend.vpc_id

  tags = {
    Name    = "backend-private-${count.index}"
    Project = "rapyd-sentinel"
  }
}
