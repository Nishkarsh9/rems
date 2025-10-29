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
