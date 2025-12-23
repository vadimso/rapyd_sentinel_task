output "vpc_id" {
  description = "ID of the main VPC"
  value       = module.vpc_main.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the main VPC"
  value       = module.vpc_main.vpc_cidr_block
}

output "gateway_cluster_name" {
  description = "Name of the gateway EKS cluster"
  value       = module.eks_gateway.cluster_name
}

output "backend_cluster_name" {
  description = "Name of the backend EKS cluster"
  value       = module.eks_backend.cluster_name
}

output "gateway_cluster_endpoint" {
  description = "Endpoint of the gateway EKS cluster"
  value       = module.eks_gateway.cluster_endpoint
}

output "backend_cluster_endpoint" {
  description = "Endpoint of the backend EKS cluster"
  value       = module.eks_backend.cluster_endpoint
}

output "gateway_subnets" {
  description = "Subnets used by gateway cluster"
  value       = slice(module.vpc_main.private_subnets, 0, 2)
}

output "backend_subnets" {
  description = "Subnets used by backend cluster"
  value       = slice(module.vpc_main.private_subnets, 2, 4)
}
