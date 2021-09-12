# Terraform Security-Group Module

## Usage
    module "application_security_group" {
        source = "git@github.com/kedwards/tf-security-group[?ref=vx.x.x]"

        ingress_rules = [
            [ "22", "22", "tcp", "Allow ssh traffic to application", ["xxx.xxx.xxx.xxx/32"]],
            [ "80", "80", "tcp", "Allow http traffic to application", ["0.0.0.0/0"]]
        ]
        egress_rules = [
            [ "0", "0", "-1", "Allow all access out", ["0.0.0.0/0"]]
        ]
        name = "keca-application"
        vpc_id = module.vpc.vpc_id

        tags = {
            Environment = "dev"
            Owner       = "Kevin Edwards"
            Terraform   = true
        }
    }

### Outputs

    output "security_group_id" {
        description = "The ID of the security group"
    }
