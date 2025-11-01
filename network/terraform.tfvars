##############################
# VPC
##############################
vpc_cidr             = "10.0.0.0/16"
instance_tenancy     = "default"
enable_dns_support   = true
enable_dns_hostnames = true
##############################
# Subnets
##############################
subnet_names = ["public-subnet-1", "private-subnet-1", "private-subnet-2"]
subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.4.0/24"]
subnet_azs   = ["us-west-1a", "us-west-1a", "us-west-1c"]

public_route_table    = "public-rt"
private_route_table   = "private-rt"
public_rt_cidr_block  = "0.0.0.0/0"
private_rt_cidr_block = "0.0.0.0/0"

# Use indexes for both public subnets
public_subnet_indexes = [0] # index 0 = public-1, index 2 = public-2

##############################
# NACL Configuration
##############################
create_nacl = true

nacl_names = ["public", "application", "database"]

nacl_rules = {
  public = {
    subnet_index = [0]
    ingress_rules = [
      { protocol = "tcp", rule_no = 100, action = "allow", cidr_block = "0.0.0.0/0", from_port = 22, to_port = 22 },
      { protocol = "tcp", rule_no = 110, action = "allow", cidr_block = "0.0.0.0/0", from_port = 1024, to_port = 65535 },
      { protocol = "-1", rule_no = 120, action = "allow", cidr_block = "0.0.0.0/0", from_port = 0, to_port = 0 }
    ]
    egress_rules = [
      { protocol = "tcp", rule_no = 100, action = "allow", cidr_block = "0.0.0.0/0", from_port = 1024, to_port = 65535 },
      { protocol = "-1", rule_no = 110, action = "allow", cidr_block = "0.0.0.0/0", from_port = 0, to_port = 0 }
    ]
  }

  application = {
    subnet_index = [1]
    ingress_rules = [
      { protocol = "tcp", rule_no = 100, action = "allow", cidr_block = "10.0.0.0/16", from_port = 22, to_port = 22 },
      { protocol = "tcp", rule_no = 110, action = "allow", cidr_block = "10.0.0.0/16", from_port = 1024, to_port = 65535 },
      # EKS API endpoint access
      { protocol = "tcp", rule_no = 120, action = "allow", cidr_block = "10.0.0.0/16", from_port = 443, to_port = 443 },
      # DNS for service discovery
      { protocol = "tcp", rule_no = 130, action = "allow", cidr_block = "10.0.0.0/16", from_port = 53, to_port = 53 },
      { protocol = "udp", rule_no = 140, action = "allow", cidr_block = "10.0.0.0/16", from_port = 53, to_port = 53 }
    ]
    egress_rules = [
      { protocol = "tcp", rule_no = 100, action = "allow", cidr_block = "10.0.0.0/16", from_port = 1024, to_port = 65535 },
      # Allow HTTPS to VPC endpoints
      { protocol = "tcp", rule_no = 110, action = "allow", cidr_block = "10.0.0.0/16", from_port = 443, to_port = 443 },
      # Allow DNS queries
      { protocol = "udp", rule_no = 120, action = "allow", cidr_block = "10.0.0.0/16", from_port = 53, to_port = 53 },
      { protocol = "tcp", rule_no = 130, action = "allow", cidr_block = "10.0.0.0/16", from_port = 53, to_port = 53 },
      # NTP for time sync
      { protocol = "udp", rule_no = 140, action = "allow", cidr_block = "10.0.0.0/16", from_port = 123, to_port = 123 },
      # Allow all outbound to AWS services via endpoints
      { protocol = "-1", rule_no = 150, action = "allow", cidr_block = "10.0.0.0/16", from_port = 0, to_port = 0 }
    ]
  }

  database = {
    subnet_index = [2]
    ingress_rules = [
      { protocol = "tcp", rule_no = 100, action = "allow", cidr_block = "10.0.0.0/16", from_port = 22, to_port = 22 },
      { protocol = "tcp", rule_no = 110, action = "allow", cidr_block = "10.0.0.0/16", from_port = 1024, to_port = 65535 }
    ]
    egress_rules = [
      { protocol = "tcp", rule_no = 100, action = "allow", cidr_block = "10.0.0.0/16", from_port = 1024, to_port = 65535 }
    ]
  }
}


##############################
# NAT Gateway
##############################
create_nat_gateway = true
nat_gateway_count  = 1
##############################
# Flow Logs
##############################
flow_logs_enabled      = false
flow_logs_traffic_type = "ALL"
flow_logs_file_format  = "parquet"

##############################
# Route 53
##############################
create_route53 = false
route53_zone   = "example.internal"

##############################
# VPC Endpoints
##############################
enable_s3_endpoint = true
service_name_s3    = "com.amazonaws.us-west-1.s3"
s3_endpoint_type   = "Gateway"

enable_ec2_endpoint      = true
service_name_ec2         = "com.amazonaws.us-west-1.ec2"
ec2_endpoint_type        = "Interface"
ec2_endpoint_subnet_type = "private"
ec2_private_dns_enabled  = true


enable_eks_endpoint = true
service_name_eks    = "com.amazonaws.us-west-1.eks"  # Fixed region!
eks_endpoint_type   = "Interface"
eks_endpoint_subnet_type = "private"
eks_private_dns_enabled = true

enable_ecr_endpoint = true  
service_name_ecr    = "com.amazonaws.us-west-1.ecr.dkr"  # Fixed region!
ecr_endpoint_type   = "Interface"
ecr_endpoint_subnet_type = "private"
ecr_private_dns_enabled = true

enable_ecr_api_endpoint = true
service_name_ecr_api    = "com.amazonaws.us-west-1.ecr.api"  # Fixed region!
ecr_api_endpoint_type   = "Interface"
ecr_api_endpoint_subnet_type = "private"
ecr_api_private_dns_enabled = true

enable_sts_endpoint = true
service_name_sts    = "com.amazonaws.us-west-1.sts"  # Fixed region!
sts_endpoint_type   = "Interface"
sts_endpoint_subnet_type = "private"
sts_private_dns_enabled = true

enable_logs_endpoint = true
service_name_logs    = "com.amazonaws.us-west-1.logs"  # Fixed region!
logs_endpoint_type   = "Interface"
logs_endpoint_subnet_type = "private"
logs_private_dns_enabled = true

enable_nlb_endpoint = false
# NLB Endpoint Configuration
service_name_nlb        = "com.amazonaws.us-east-1.elasticloadbalancing"
nlb_endpoint_type       = "Interface"
nlb_private_dns_enabled = false


##############################
# Application Load Balancer
##############################
create_alb                 = false
internal                   = false
enable_deletion_protection = false
alb_certificate_arn        = ""
access_logs = {
  enabled = false
  bucket  = ""
  prefix  = ""
}

##############################
# Network Load Balancer
##############################
create_nlb  = false
is_internal = false

##############################
# Tags & Metadata
##############################
provisioner = "terraform"
tags = {
  Environment = "dev"
  Owner       = "Nishkarsh"
}




##############################
# Key Pair Configuration
##############################
create_key_pair       = true
create_private_key    = true
key_pair_name         = "rems-key"
private_key_algorithm = "RSA"
private_key_rsa_bits  = 4096
public_key_path       = ""                                           # Leave blank if you're generating the key
key_output_dir        = "/home/ubuntu/keys" # Directory where PEM file will be saved

env     = "prod"
owner   = "nishkarsh"
program = "otcloudkit"
region  = "us-west-1"

enable_alb_sg      = false
enable_endpoint_sg = true
enable_nlb_sg      = false

endpoint_ingress_rules = [
  {
    description  = "Allow HTTPS from private subnets"
    from_port    = 443
    to_port      = 443
    protocol     = "tcp"
    cidr         = ["10.0.0.0/16"]
  }
]

endpoint_egress_rules = [
  {
    description  = "Allow all outbound"
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr         = ["0.0.0.0/0"]
  }
]

