resource "random_string" "db_password" {
  length  = 24
  lower   = true
  upper   = true
  number  = true
  special = false
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.environment}/db/terraform/admin"
  description = "Admin password for ${var.db_name} db"
  type        = "SecureString"
  value       = random_string.db_password.result
  overwrite   = true
}

resource "aws_db_subnet_group" "this" {
  name       = "main"
  subnet_ids = var.subnets

  tags = {
    Name = "My DB subnet group"
  }
}


resource "aws_db_parameter_group" "this" {
  name   = var.db_name
  family = "postgres10"

  # Enable logging
  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # in milliseconds
  }

  tags = {
    "Name" = "Postgres param group for ${var.db_name}"
  }
}

resource "aws_db_instance" "this" {
  identifier           = var.db_name
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  name                 = var.db_name
  username             = var.username
  password             = random_string.db_password.result
  db_subnet_group_name = aws_db_subnet_group.this.name
  parameter_group_name = aws_db_parameter_group.this.id
  publicly_accessible  = false
  skip_final_snapshot  = true

  vpc_security_group_ids = [var.security_group]

  tags = merge(
    {
      "Name" = format("%s-instance", var.db_name)
    },
    var.tags,
    var.db_tags
  )
}
