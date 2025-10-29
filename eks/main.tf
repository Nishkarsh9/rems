
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0.8"

  name = var.name

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
  eks_managed_node_groups              = var.eks_managed_node_groups
  vpc_id                               = "vpc-0e4dfafe0baa3419f"
  subnet_ids = [
    "subnet-0b8efbaeb5f81d557",
    "subnet-0f6eb2b3775931db8"
  ]
}

