# Terraform RDS Module

## Usage
    module "rds_database" {
        source = "git::git@github.com:kedwards/tf-rds.git[?ref=vx.x.x]"

        db_name         = "appdatabase"
        engine          = "postgres"
        engine_version  = "10.4"
        region          = "us-east-1"
        security_group  = "sg-xxxxxxxxxxxx"
        subnets         = ["subnet-xxxxxxxx", "subnet-xxxxxxxxx"]
        username        = "terraform"
        
        tags = {
            Environment = "dev"
            Owner       = "Kevin Edwards"
            Terraform   = true
        }
    }

### Outputs

    output "db_host" {
        description = "The database host address."
        value       = aws_db_instance.this.address
    }

    output "db_user" {
        description = "The database username."
        value       = aws_db_instance.this.username
    }

    output "db_password" {
        description = "The database password."
        value       = random_string.db_password.result
    }

    output "db_database" {
        description = "The nme for the adatabase."
        value       = aws_db_instance.this.name
    }
