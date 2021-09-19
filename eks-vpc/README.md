# Terraform EKS-VPC Module

## Usage

```
locals {
  common_tags = {
    ManagedBy = "terraform"
  }
}

module "vpc" {
  source                          = "../../../../terraform-modules/eks-vpc"
  clusters_name_prefix            = var.clusters_name_prefix
  eks_vpc_block                   = var.vpc_block
  eks_public_subnets_prefix_list  = var.public_subnets_prefix_list
  eks_private_subnets_prefix_list = var.private_subnets_prefix_list
  common_tags                     = local.common_tags
}
```

### Outputs

```
output "vpc_id" {
  value = module.vpc.eks_cluster_vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.eks_private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.eks_public_subnet_ids
}
```
