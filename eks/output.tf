output "node_security_group_arn" {
  value       = module.eks.node_security_group_arn
  description = "ARN of the EKS node security group"
}

output "node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "ID of the EKS node security group"
}

output "eks_managed_node_groups" {
  value       = module.eks.eks_managed_node_groups
  description = "Details of the EKS managed node groups"
}

###########################################################
# Outputs
###########################################################
output "vpc_id" {
  description = "VPC ID used by EKS cluster"
  value       = data.terraform_remote_state.network.outputs.vpc_id
}

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster CA certificate data"
  value       = module.eks.cluster_certificate_authority_data
}
