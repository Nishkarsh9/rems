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

output "subnet_ids_by_name" {
  description = "Subnet IDs mapped from names"
  value       = local.subnet_ids_by_name
}
