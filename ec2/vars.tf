#
# required
#
variable "ami" {
  description = "The ami to use for the instance."
  type        = string
}

variable "provisioning_key" {
  description = "A key that can be used to connect and provision instances in AWS."
  type        = string
}

variable "subnet" {
  description = "The subnet to place the instance."
  type        = string
}

variable "vpc_id" {
  description = "The vpc to deploy resources into."
  type        = string
}

#
# optional
#
variable "associate_public_ip_address" {
  default     = true
  description = "Associate a public IP addrss on launch."
  type        = bool
}

variable "create_key_pair" {
  default     = false
  description = "Whether to create a key pair."
  type        = bool
}

variable "enable_monitoring" {
  default     = false
  description = "Enable detailed monitoring of the instance."
  type        = bool
}

variable "instance_tags" {
  default     = {}
  description = "Additional tags for the instance"
  type        = map(string)
}

variable "instance_count" {
  default     = 1
  description = "How many instances to create."
  type        = number
}

variable "instance_type" {
  default     = "t2.micro"
  description = "The instance type to use for the instance."
  type        = string
}

variable "name" {
  default     = "instance"
  description = "The name of the instance."
  type        = string
}

variable "public_key" {
  default     = ""
  description = "The publick_key for use with the instance."
  type        = string
}

variable "security_groups" {
  default     = []
  description = "The SGs to access the instance."
  type        = list(string)
}

variable "tags" {
  default     = {}
  description = "Additional tags for the instance"
  type        = map(string)
}

variable "user_data" {
  default     = ""
  description = "The subnet to place the instance."
  type        = string
}

variable "volume_size" {
  default     = 20
  description = "The volume size to use for the instance (GB)."
  type        = number
}

variable "volume_type" {
  default     = "gp2"
  description = "The volume type to use for data storage on the instance."
  type        = string
}
