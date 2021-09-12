# Terraform EC2-HA Module

## Usage

    module "app" {
        source = "git::git@github.com:kedwards/tf-ec2-ha.git?ref=[vx.x.x]"

        ami                 = "ami-xxxxxxxx"
        alb_security_groups = ["sg-xxxxxxxxxxxxxxx"]
        subnets             = local.app_subnets
        launch_name_prefix  = "instanceX"
        name                = "instanceX"
        alb_health_path     = "/test.htm"
        provisioning_key    = "provision_key_name"
        security_groups     = ["sg-xxxxxxxxxxxxxxx"]
        target_group_port   = "8080"
        user_data           = base64encode(data.template_file.user_data.rendered)
        vpc_id              = "vpc-xxxxxxxxx"
        vpc_zone_identifier = ["subnet-xxxxxxxxx"]
    }

### Outputs

    output "dns_name" {
        description = "The dns name of the load balancer"
        value       = aws_lb.this.dns_name
    }
