output "gateway_vpc_id" {
  description = "ID of the gateway VPC"
  value       = module.vpc_gateway.vpc_id
}

output "backend_vpc_id" {
  description = "ID of the backend VPC"
  value       = module.vpc_backend.vpc_id
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

output "vpc_peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.gateway_backend.id
}
