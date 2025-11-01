ami_ssm_parameter = ""
region            = "us-west-1"
availability_zone = "us-west-1a"
create_eip        = true
ebs_optimized     = true
instance_type     = "c7i-flex.large"
key_name          = "rems-key"
create_key_pair   = false
public_key_path   = "/home/ubuntu/keys/rems-key.pem"

create_security_group          = true
security_group_use_name_prefix = true
security_group_name            = "ec2-sg"
security_group_description     = "Web EC2 Security Group"
associate_public_ip_address    = true
vpc_security_group_ids         = []

ec2_security_group_tags = {
  Name = "web-sg"
}
security_group_ingress_rules = {
  ssh = {
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
    description = "Allow SSH"
  }

}

security_group_egress_rules = {
  all_ipv4 = {
    cidr_ipv4   = "0.0.0.0/0"
    ip_protocol = "-1"
    description = "Allow all outbound IPv4 traffic"
  }
}

tags = {
  Environment = "dev"
  Project     = "bastion"
  Name        = "bastion-host"
}

instance_tags = {
  Name = "web-server"
}
ec2_name = "test-ec2"

backend_region = "us-west-1"
bucket         = "rems-temp"
bucket_key     = "networking/terraform.tfstate"

# Enable IAM instance profile creation
create_iam_instance_profile = true


# Optional: do not prefix role name
ec2_iam_role_use_name_prefix = false

# Attach required IAM policies
ec2_iam_role_policies = {
  ssm = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  iam = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  eks_full   = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  eks_vpc    = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  cloudwatch = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ec2_full   = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  iam_full   = "arn:aws:iam::aws:policy/IAMFullAccess"
  s3_readonly = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  kms_full    = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

