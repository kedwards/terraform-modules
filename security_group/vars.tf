#
# required
#
variable "vpc_id" {
  description = "The vpc id use."
  type        = string
}

variable "name" {
  description = "The nae of the security group."
  type        = string
}

#
# optional
#
variable "create" {
  default     = true
  description = "Whether to create security group and all rules"
  type        = bool
}

variable "description" {
  default     = "Security Group"
  description = "Description for the security group."
  type        = string
}

variable "egress_ipv6_cidr_blocks" {
  default     = ["::/0"]
  description = "List of IPv6 CIDR ranges to use on all egress rules"
  type        = list(string)
}

variable "egress_rules" {
  default     = []
  description = "List of egress rules to create by name"
  type        = list(any)
}

variable "ingress_cidr_blocks" {
  default     = []
  description = "List of IPv4 CIDR ranges to use on all ingress rules"
  type        = list(string)
}

variable "ingress_ipv6_cidr_blocks" {
  default     = []
  description = "List of IPv6 CIDR ranges to use on all ingress rules"
  type        = list(string)
}

variable "ingress_rules" {
  default     = []
  description = "List of ingress rules to create by name"
  type        = list(any)
}

variable "tags" {
  default     = {}
  description = "A mapping of tags to assign to security group"
  type        = map(string)
}
