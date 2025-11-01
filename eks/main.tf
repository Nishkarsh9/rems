data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.bucket
    key    = var.network_bucket_key
    region = var.region
  }
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.network.outputs.vpc_id]
  }
}

data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.all.ids)
  id       = each.value
}

###########################################################
# Build dynamic node group subnet mapping from subnet names
###########################################################
locals {
  subnet_ids_by_name = {
    for k, s in data.aws_subnet.details :
    s.tags["Name"] => s.id
  }
}

# VPC Endpoints for EKS Worker Nodes - THESE ARE OUTSIDE THE MODULE
resource "aws_vpc_endpoint" "eks" {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  service_name        = "com.amazonaws.us-west-1.eks"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids  = [data.terraform_remote_state.network.outputs.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "eks-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  service_name        = "com.amazonaws.us-west-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids  = [data.terraform_remote_state.network.outputs.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ecr-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  service_name        = "com.amazonaws.us-west-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids  = [data.terraform_remote_state.network.outputs.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ecr-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  service_name        = "com.amazonaws.us-west-1.sts"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids  = [data.terraform_remote_state.network.outputs.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "sts-endpoint"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  service_name        = "com.amazonaws.us-west-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids  = [data.terraform_remote_state.network.outputs.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "logs-endpoint"
  }
}

# Add these SSM endpoints - CRITICAL for node communication
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  service_name        = "com.amazonaws.us-west-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids  = [data.terraform_remote_state.network.outputs.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  service_name        = "com.amazonaws.us-west-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids  = [data.terraform_remote_state.network.outputs.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ssm-messages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  service_name        = "com.amazonaws.us-west-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids  = [data.terraform_remote_state.network.outputs.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ec2-messages-endpoint"
  }
}

# EKS Module - THIS IS SEPARATE FROM THE VPC ENDPOINTS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0.8"

  name = var.name

  subnet_ids = values(local.subnet_ids_by_name)
  endpoint_public_access = true
  endpoint_private_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true
  cluster_tags                         = var.cluster_tags
  create_iam_role                      = var.create_iam_role
  create_node_iam_role                 = var.create_node_iam_role
  create_node_security_group           = var.create_node_security_group
  node_security_group_name             = var.node_security_group_name
  node_security_group_additional_rules = var.node_security_group_additional_rules
  addons                               = var.addons
  addons_timeouts                      = var.addons_timeouts
  iam_role_additional_policies         = var.iam_role_additional_policies
  node_security_group_tags             = var.node_security_group_tags
  create_security_group                = var.create_security_group
  enable_auto_mode_custom_tags         = var.enable_auto_mode_custom_tags
  node_iam_role_additional_policies    = var.node_iam_role_additional_policies
  node_iam_role_tags                   = var.node_iam_role_tags
  vpc_id                               = data.terraform_remote_state.network.outputs.vpc_id
   

     enable_irsa = true

  access_entries = {
    for k, ac in var.access_entries :
    k => {
      principal_arn      = ac.principal_arn
      kubernetes_groups  = ac.kubernetes_groups

      policy_associations = {
        for pk, pol in ac.access_policies :
        pk => {
          policy_arn = pol.policy_arn
          access_scope = pol.access_scope
        }
      }
    }
  }
  
  eks_managed_node_groups = {
    for name, cfg in var.eks_managed_node_groups :
    name => merge(cfg, {
      subnet_ids = [
        for s in lookup(var.nodegroup_subnet_names, name, []) :
        lookup(local.subnet_ids_by_name, s)
      ]
    })
  }
}

