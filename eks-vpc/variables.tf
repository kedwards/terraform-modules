variable "eks_vpc_block" {
  type = string
}

variable "eks_private_subnets_prefix_list" {
  type = list(string)
}

variable "eks_public_subnets_prefix_list" {
  type = list(string)
}

variable "clusters_name_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "one_nat_gateway_per_az" {
  type    = bool
  default = false
}