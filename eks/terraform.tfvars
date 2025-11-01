region             = "us-west-1"
name               = "prod-otcloudkit-eks-cluster"
bucket             = "rems-temp"
network_bucket_key = "networking/terraform.tfstate"

create_iam_role            = true
create_node_iam_role       = true
create_security_group      = true
create_node_security_group = true

cluster_tags = {
  name        = "rems-eks"
  environment = "nonprod"
  team        = "infra"
  application = "demo"
}

addons = {
  coredns = {
    name = "coredns"
    most_recent = true
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    before_compute = false
  }
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
  kube-proxy = {
    name                        = "kube-proxy"
    before_compute              = true
    resolve_conflicts_on_update = "OVERWRITE"
    resolve_conflicts_on_create = "OVERWRITE"
    most_recent                 = true
    tags = {
      Environment = "nonprop"
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

nodegroup_subnet_names = {
  olly-ng1 = ["prod-otcloudkit-private-subnet-1"]
}

eks_managed_node_groups = {
  olly-ng1 = {
    create                       = true
    kubernetes_version           = "1.31"
    name                         = "olly-ng1"
    ami_type                     = "AL2023_x86_64_STANDARD"
    instance_types               = ["t3.micro"]
    desired_size                 = 1
    min_size                     = 1
    max_size                     = 1
    capacity_type                = "ON_DEMAND"
    create_launch_template       = false
    use_custom_launch_template   = false
    launch_template_name         = "eks-ng1-launch-template"
    launch_template_description  = "Custom launch template for eks-ng1"
    launch_template_tags         = { Environment = "nonprod", Owner = "DevOps" }
    tag_specifications           = ["instance", "volume"]
    disk_size                    = 20
   
    enable_bootstrap_user_data = true
    bootstrap_extra_args       = "--use-max-pods false --kubelet-extra-args '--max-pods=20'"

    # FIXED: Removed trailing commas
    iam_role_additional_policies = {
      EKSWorkerPolicy  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      ECRReadOnly      = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      EKSCNIPolicy     = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      S3ReadOnlyAccess = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
      CWAgent          = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      SSMCore          = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    tags = { 
      Name = "olly-ng1-node", 
      type = "on-demand" 
    }
  }
}

node_security_group_additional_rules = {
  egress_all = {
    description      = "Node all egress"
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    type             = "egress"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress_ssh = {
    description = "SSH access"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    type        = "ingress"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

access_entries = {
  devops_access = {
    principal_arn = "arn:aws:iam::966199403857:user/devops"
    kubernetes_groups = ["devops"]
    access_policies = {
      view_policy = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
        access_scope = {
          type = "cluster"
        }
      }
    }
  }
}
