#
# required
#
variable "alb_security_groups" {
  description = "The list of security groups to attach with the load balancer."
  type        = list(string)
}

variable "ami" {
  description = "The ami to use."
  type        = string
}

variable "app_subnets" {
  description = "The sunets the load balancer will use."
  type        = list(string)
}

variable "path" {
  description = "The path for the health check."
  type        = string
}

variable "provisioning_key" {
  description = "A key that can be used to connect and provision instances in AWS."
  type        = string
}

variable "name" {
  description = "Name for the platform."
  type        = string
}

variable "security_groups" {
  description = "A list of security groups to attach to the platform."
  type        = string
}

variable "target_group_port" {
  description = "Alb target port."
  type        = string
}

variable "user_data" {
  description = "A user_data script to be run on instance init."
  type        = any
}

variable "vpc_id" {
  description = "The vpc id use."
  type        = string
}

#
# optional
#
variable "alb_tags" {
  default     = {}
  description = "Additional tags for the alb"
  type        = map(string)
}

variable "create" {
  default     = true
  description = "Whether to create security group and all rules"
  type        = bool
}

variable "environment" {
  default     = "dev"
  description = "The environment name."
  type        = string
}

variable "health_check" {
  default     = {}
  description = "Load balanncer health check"
  type        = map(string)
}

variable "instance_type" {
  default     = "t2.micro"
  description = "The instance type to use instance."
  type        = string
}

variable "load_balancer_type" {
  default     = "application"
  description = "Type of load balancer"
  type        = string
}

variable "internal" {
  default     = false
  description = "A map of tags to add to all resources."
  type        = bool
}

variable "protocol" {
  default     = "HTTP"
  description = "Protocol used to communicate with target group."
  type        = string
}

variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources."
  type        = map(string)
}