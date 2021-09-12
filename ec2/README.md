# Terraform EC2 Module

## Usage

    module "mongodb" {
        source = "git::git@github.com:kedwards/tf-ec2.git[?ref=vx.x.x]"

        ami              = "ami-xxxxxxxx"
        instance_count   = 1
        name             = "instance-name"
        provisioning_key = "provision_key_name"
        subnet           = "us-east-1a"
        user_data        = data.template_file.user_data.rendered
        security_groups  = ["sg-xxxxxxxxxxxxxxx"]
        
        tags = merge(
            local.tags,
            {
                Name = "instance-name"
                Type = "instance-identifier"
            }
        )
    }

### Outputs

    output "public_dns" {
        description = "The private DNS adress for the instance"
    }

    output "public_ip" {
        description = "The private IP address of the instance"
    }

    output "private_dns" {
        description = "The private DNS adress for the instance"
    }

    output "private_ip" {
        description = "The private IP address of the instance"
    }
