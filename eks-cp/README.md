# Terraform EKS-Control Plane Module

## Usage

```
locals {
  common_tags = {
    ManagedBy   = "terraform"
    ClusterName = format("%s-%s", var.clusters_name_prefix, terraform.workspace)
  }
}

module "eks" {
  source            = "git::https://github.com:kedwards/terraform_modules.git//eks-cp"
  vpc_id            = var.vpc_id
  private_subnets   = var.private_subnet_ids
  public_subnets    = var.public_subnet_ids
  cluster_full_name = format("%s-%s", var.clusters_name_prefix, terraform.workspace)
  cluster_version   = var.cluster_version
  common_tags       = local.common_tags
}
```

### Variables

```
variable "cluster_full_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
```

### Outputs

```
output "security_group" {
  value = aws_security_group.eks_cluster_sg.id
}

output "ca" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
```
