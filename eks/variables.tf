# --------------------------
# Cluster basics
variable "name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "gokwik-eks-cluster"
}

variable "region" {
  description = "AWS region where the resources will be created"
  type        = string
  default     = "us-east-2"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# --------------------------
# IAM roles
variable "create_iam_role" {
  description = "Determines whether an IAM role is created for the cluster"
  type        = bool
  default     = true
}

variable "create_node_iam_role" {
  description = "Determines whether an EKS Auto node IAM role is created"
  type        = bool
  default     = true
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "node_iam_role_additional_policies" {
  description = "Additional policies to be added to the EKS Auto node IAM role"
  type        = map(string)
  default     = {}
}

variable "node_iam_role_tags" {
  description = "A map of additional tags to add to the EKS Auto node IAM role created"
  type        = map(string)
  default     = {}
}

# --------------------------
# Cluster tags
variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  type        = map(string)
  default     = {}
}

variable "enable_auto_mode_custom_tags" {
  description = "Determines whether to enable permissions for custom tags resources created by EKS Auto Mode"
  type        = bool
  default     = true
}

# --------------------------
# Node groups
variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions"
  type = map(object({
    create                       = optional(bool, true)
    kubernetes_version           = string
    name                         = string
    subnet_ids                   = optional(list(string), [])
    ami_type                     = string
    instance_types               = list(string)
    desired_size                 = number
    min_size                     = number
    max_size                     = number
    capacity_type                = string
    create_launch_template       = optional(bool, false)
    use_custom_launch_template   = optional(bool, false)
    launch_template_name         = optional(string)
    launch_template_description  = optional(string)
    launch_template_tags         = optional(map(string))
    tag_specifications           = optional(list(string))
    disk_size                    = optional(number)
    iam_role_additional_policies = optional(map(string), {})
    tags                         = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# EKS Addons
################################################################################

variable "addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type = map(object({
    name                 = optional(string) # will fall back to map key
    before_compute       = optional(bool, false)
    most_recent          = optional(bool, true)
    addon_version        = optional(string)
    configuration_values = optional(string)
    pod_identity_association = optional(list(object({
      role_arn        = string
      service_account = string
    })))
    preserve                    = optional(bool, true)
    resolve_conflicts_on_create = optional(string, "NONE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }), {})
    tags = optional(map(string), {})
  }))
  default = null
}

variable "addons_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster addons"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {}
}

# --------------------------
# Security groups
variable "create_security_group" {
  description = "Determines if a security group is created for the cluster"
  type        = bool
  default     = true
}

variable "create_node_security_group" {
  description = "Determines whether to create a security group for the node groups"
  type        = bool
  default     = true
}

variable "node_security_group_name" {
  description = "Name to use on node security group created"
  type        = string
  default     = null
}

variable "node_security_group_tags" {
  description = "A map of additional tags to add to the node security group created"
  type        = map(string)
  default     = {}
}

variable "node_security_group_additional_rules" {
  description = "Additional security group rules for the node security group"
  type = map(object({
    protocol                      = string
    from_port                     = number
    to_port                       = number
    type                          = string
    description                   = string
    cidr_blocks                   = optional(list(string))
    ipv6_cidr_blocks              = optional(list(string))
    self                          = optional(bool)
    source_security_group_id      = optional(string)
    source_cluster_security_group = optional(bool)
  }))
  default = {}
}

# # --------------------------
# # Remote state / S3
 variable "bucket" {
   description = "S3 bucket name for remote state storage"
   type        = string
 }

 variable "network_bucket_key" {
   description = "S3 key for the network remote state"
   type        = string
   default     = ""
 }

variable "nodegroup_subnet_names" {
  description = "Mapping of node group names to lists of subnet names used for those node groups"
  type        = map(list(string))
  default     = {}
}

variable "access_entries" {
  description = "EKS access entries for IAM → Kubernetes access"
  type = map(object({
    principal_arn     = string
    kubernetes_groups = list(string)

    access_policies = map(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string))
      })
    }))
  }))
  default = {}
}
