
#
# optional
#
variable "read_capacity" {
  default     = 1
  description = "The read capacity of the table."
  type        = string
}

variable "write_capacity" {
  default     = 1
  description = "The write capacity of the table."
  type        = string
}

#
# required
#
variable "email" {
  description = "The email contact address responsibel for the resurces."
  type        = string
}
variable "id" {
  description = "Use to build a unique name for the s3 bucket and dynamo db table."
  type        = string
}

variable "owner" {
  description = "Owner of the resources, use for tagging."
  type        = string
}

variable "region" {
  description = "The region the resources will be deployed to."
  type        = string
}