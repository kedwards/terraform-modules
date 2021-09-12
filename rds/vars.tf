#
# required
#
variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_subnet_group" {
  description = "The subnet where the db will be placed in."
  type        = string
}

variable "engine" {
  description = "The db engine to use."
  type        = string
}

variable "engine_version" {
  description = "The db engine version to use."
  type        = string
}

variable "region" {
  description = "The region the db is deployed to."
  type        = string
}

variable "security_group" {
  description = "The security group the db will be placed in."
  type        = string
}

variable "subnets" {
  description = "The subnets the db will be placed in."
  type        = list(string)
}

variable "username" {
  description = "The name of the db_user"
  type        = string
}

#
# optional
#
variable "allocated_storage" {
  default     = 10
  description = "The size of strage allocated for the Db (GB)."
  type        = number
}

variable "db_tags" {
  default     = {}
  description = "Additional tags to the db instance."
  type        = map(string)
}

variable "environment" {
  default     = "test"
  description = "The name of the environment"
  type        = string
}

variable "instance_class" {
  default     = "db.t2.micro"
  description = "The name of the db instance class."
  type        = string
}

variable "storage_type" {
  default     = "gp2"
  description = "The type of storage"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Additional tags to the db instance."
  type        = map(string)
}