locals {
  id     = var.id
  name   = "${local.id}-${local.region}"
  region = var.region
  tags = {
    Owner     = var.owner
    Email     = var.email
    Terraform = true
  }
}

resource "aws_s3_bucket" "this" {
  bucket = "${local.name}-tfstate"
  acl    = "private"
  region = local.region
  tags   = local.tags

  lifecycle {
    prevent_destroy = "true"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "state"
    prefix  = "state/"
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }

  depends_on = [aws_dynamodb_table.this]
}

resource "aws_dynamodb_table" "this" {
  name           = "${local.name}-tfstate-lock"
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "LockID"

  #
  # The table must have a primary key named LockID.
  # If not present, locking will be disabled.
  #
  attribute {
    name = "LockID"
    type = "S"
  }
}

