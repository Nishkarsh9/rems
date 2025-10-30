region             = "us-west-1"
name               = "rems-cluster1"
bucket             = "rems-temp"
network_bucket_key = "networking/terraform.tfstate"

create_iam_role            = true
create_node_iam_role       = true
create_security_group      = true
create_node_security_group = true

cluster_tags = {
  name        = "eks-istio-demo"
  environment = "nonprod"
  team        = "infra"
  application = "demo"
}

addons = {
  vpc-cni = {
    name                        = "vpc-cni"
    before_compute              = true
    resolve_conflicts_on_update = "OVERWRITE"
    resolve_conflicts_on_create = "OVERWRITE"
    most_recent                 = true
    tags = {
      Environment = "nonprod"
      Team        = "infra"
    }
  }

  coredns = {
    name                        = "coredns"
    before_compute              = true
    resolve_conflicts_on_update = "OVERWRITE"
    resolve_conflicts_on_create = "OVERWRITE"
    most_recent                 = true
    tags = {
      Environment = "nonprod"
      Team        = "infra"
    }
  }

  kube-proxy = {
    name                        = "kube-proxy"
    before_compute              = true
    resolve_conflicts_on_update = "OVERWRITE"
    resolve_conflicts_on_create = "OVERWRITE"
    most_recent                 = true
    tags = {
      Environment = "nonprod"
      Team        = "infra"
    }
  }
}
addons_timeouts = {
  create = "15m"
  update = "15m"
  delete = "15m"
}

enable_auto_mode_custom_tags = true

node_security_group_name = "eks-node-sg"
node_security_group_tags = {
  name        = "eks-node-sg"
  environment = "nonprod"
  team        = "infra"
  application = "demo"
}

eks_managed_node_groups = {
  olly-ng1 = {
    create                       = true
    kubernetes_version           = "1.31"
    name                         = "olly-ng1"
    subnet_ids                   = ["subnet-06fd7ace7e41c652f" , "subnet-0231c74df1eecddc8"]
    ami_type                     = "AL2023_x86_64_STANDARD"
    instance_types               = ["t3.medium"]
    desired_size                 = 2
    min_size                     = 1
    max_size                     = 3
    capacity_type                = "ON_DEMAND"
    create_launch_template       = true
    use_custom_launch_template   = false
    launch_template_name         = "eks-ng1-launch-template"
    launch_template_description  = "Custom launch template for eks-ng1"
    launch_template_tags         = { Environment = "nonprod", Owner = "DevOps" }
    tag_specifications           = ["instance:Name=eks-ng1-instance,Environment=nonprod"]
    disk_size                    = 20
    iam_role_additional_policies = {}
    tags                         = { Name = "olly-ng1-node", type = "on-demand" }
  }

  on-demand-ng = {
    create                      = true
    kubernetes_version          = "1.31"
    name                        = "on-demand-ng"
    subnet_ids                  = ["subnet-06fd7ace7e41c652f" , "subnet-0231c74df1eecddc8"]
    ami_type                    = "AL2023_x86_64_STANDARD"
    instance_types              = ["t3.medium"]
    desired_size                = 2
    min_size                    = 1
    max_size                    = 3
    capacity_type               = "ON_DEMAND"
    create_launch_template      = true
    use_custom_launch_template  = false
    launch_template_name        = "eks-ondemand-launch-template"
    launch_template_description = null
    launch_template_tags        = {}
    tag_specifications          = []
    disk_size                   = 20
    iam_role_additional_policies = {
      EKSWorkerPolicy  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      ECRReadOnly      = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      EKSCNIPolicy     = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
      S3ReadOnlyAccess = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
      CWAgent          = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    }
    tags = { Name = "on-demand-node", type = "on-demand" }
  }

}

node_security_group_additional_rules = {
  allow_http_ingress = {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    type        = "ingress"
    description = "Allow HTTP traffic from the internet"
    cidr_blocks = ["0.0.0.0/0"]
  }

  allow_https_ingress = {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    type        = "ingress"
    description = "Allow HTTPS traffic from the internet"
    cidr_blocks = ["0.0.0.0/0"]
  }

  allow_all_internal = {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    type        = "ingress"
    description = "Allow all traffic from cluster nodes"
    self        = true
  }

  allow_cluster_to_nodes = {
    protocol                      = "tcp"
    from_port                     = 1025
    to_port                       = 65535
    type                          = "ingress"
    description                   = "Allow traffic from control plane to nodes"
    source_cluster_security_group = true
  }
}
