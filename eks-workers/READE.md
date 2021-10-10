# Terraform EKS-Workers Module

## Usage

```
locals {
  common_tags = {
    ManagedBy   = "terraform"
    ClusterName = format("%s-%s", var.clusters_name_prefix, terraform.workspace)
  }
}

module "eks-workers" {
  source                 = ""git::https://github.com:kedwards/terraform_modules.git//eks-workers"
  vpc_id                 = var.vpc_id
  private_subnet_ids     = var.private_subnets
  cluster_full_name      = var.cluster_full_name
  cluster_endpoint       = module.eks.endpoint
  cluster_ca             = module.eks.ca
  cluster_security_group = module.eks.security_group
  workers_ami_id         = data.aws_ssm_parameter.workers_ami_id.value
  workers_instance_type  = var.workers_instance_type
  workers_number_max     = var.workers_number_max
  workers_number_min     = var.workers_number_min
  workers_storage_size   = var.workers_storage_size
  common_tags            = var.common_tags
}
```

### Variables

```
variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_full_name" {
  type = string
}

variable "cluster_security_group" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca" {
  type = string
}

variable "workers_ami_id" {
  type = string
}

variable "workers_instance_type" {
  type = string
}

variable "workers_number_min" {
  type = string
}

variable "workers_number_max" {
  type = string
}
variable "workers_storage_size" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

```

### Outputs

```
output "asg_names" {
  value = aws_autoscaling_group.workers.name
}

output "security_group_id" {
  value = aws_security_group.workers.id
}

output "iam_role_arn" {
  value = aws_iam_role.workers.arn
}

output "iam_role_name" {
  value = aws_iam_role.workers.name
}

output "tag" {
  value = format("kubernetes.io/cluster/%s", var.cluster_full_name)
}

output "instance_profile" {
  value = aws_iam_instance_profile.workers.arn
}

output "userdata" {
  value = local.workers_userdata
}

output "authconfig" {
  value = local.authconfig
}

```
