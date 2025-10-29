
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.2"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.bucket
    key    = var.bucket_key
    region = var.backend_region
  }
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.0.2"

  # Basic Configuration
  name              = var.ec2_name
  ami               = data.aws_ami.ubuntu_2204.id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  key_name          = var.create_key_pair ? aws_key_pair.this[0].key_name : var.key_name
  # Network Settings
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  security_group_vpc_id       = data.terraform_remote_state.network.outputs.vpc_id
  associate_public_ip_address = var.create_eip ? true : false
  create_eip                  = var.create_eip
  # Block Device Configuration
  ebs_volumes            = var.ebs_volumes
  ephemeral_block_device = var.ephemeral_block_device
  ebs_optimized          = var.ebs_optimized
  # Advanced EC2 Options
  cpu_options             = var.cpu_options
  cpu_credits             = var.cpu_credits
  get_password_data       = var.get_password_data
  host_id                 = var.host_id
  monitoring              = var.monitoring
  metadata_options        = var.metadata_options
  instance_market_options = var.instance_market_options
  launch_template         = var.launch_template
  user_data               = var.user_data
  # IAM Role/Profile
  create_iam_instance_profile   = var.create_iam_instance_profile
  iam_role_use_name_prefix      = var.ec2_iam_role_use_name_prefix
  iam_role_permissions_boundary = var.ec2_iam_role_permissions_boundary
  iam_role_policies             = var.ec2_iam_role_policies
  # Security Group Configuration
  create_security_group          = var.create_security_group
  security_group_name            = var.security_group_name
  security_group_description     = var.security_group_description
  security_group_use_name_prefix = var.security_group_use_name_prefix
  security_group_ingress_rules   = var.security_group_ingress_rules
  security_group_egress_rules    = var.security_group_egress_rules
  # Tags
  tags = var.tags
  instance_tags = merge(
    var.tags,
    var.instance_tags,
    { "Name" = var.ec2_name },
  )
}


resource "aws_key_pair" "this" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}
