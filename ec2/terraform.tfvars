ami_ssm_parameter = ""
region            = "us-west-1"
availability_zone = "us-west-1a"
create_eip        = true
ebs_optimized     = true
instance_type     = "t3.micro"
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
