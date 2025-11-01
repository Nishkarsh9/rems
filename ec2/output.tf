################################################################################
# EC2 Instance Outputs
################################################################################

output "instance_id" {
  value       = module.ec2-instance.id
  description = "The ID of the EC2 instance"
}

output "instance_arn" {
  value       = module.ec2-instance.arn
  description = "The ARN of the EC2 instance"
}
################################################################################
# EBS Volume(s)
################################################################################

output "ebs_volumes_ids" {
  value       = module.ec2-instance.ebs_volumes
  description = "Map of EBS volumes and their attributes"
}

output "ami_id" {
  value       = module.ec2-instance.ami
  description = "The AMI ID used for the instance"

}
