terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.bucket
    key    = var.network_bucket_key
    region = "us-west-1"
  }
}

# Use subnet names directly from network state output instead of mapping from tags
locals {
  subnet_ids_by_name = data.terraform_remote_state.network.outputs.subnet_ids
}

# EKS Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0.8"

  name = var.name

  # Use all private subnets for cluster
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  
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
