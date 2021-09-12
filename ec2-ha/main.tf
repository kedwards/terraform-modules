resource "aws_launch_configuration" "this" {
  # Launch Configurations cannot be updated after creation with the AWS API.
  # In order to update a Launch Configuration, Terraform will destroy the
  # existing resource and create a replacement.
  #
  # We're only setting the name_prefix here,
  # Terraform will add a random string at the end to keep it unique.
  associate_public_ip_address = false
  enable_monitoring           = var.enable_monitoring
  image_id                    = var.ami
  instance_type               = var.instance_type
  key_name                    = var.provisioning_key
  name_prefix                 = var.launch_name_prefix
  security_groups             = var.security_groups
  user_data                   = var.user_data

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
    encrypted   = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  # Force a redeployment when launch configuration changes.
  # This will reset the desired capacity if it was changed due to
  # autoscaling events.
  name = "${aws_launch_configuration.this.name}-asg"

  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = var.health_check_type
  launch_configuration      = aws_launch_configuration.this.id
  max_size                  = var.max_size
  min_size                  = var.min_size
  vpc_zone_identifier       = var.vpc_zone_identifier

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tags = var.asg_tags
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  alb_target_group_arn   = aws_alb_target_group.this.arn
}

resource "aws_lb" "this" {
  name = "${var.name}-lb"
  # tfsec:ignore:AWS005
  internal           = var.internal_lb ? true : false
  load_balancer_type = var.load_balancer_type
  security_groups    = var.alb_security_groups
  subnets            = var.subnets

  drop_invalid_header_fields = true

  tags = merge(
    {
      "Name" = format("%s-aws-lb", var.name)
    },
    var.tags,
    var.alb_tags,
  )
}

resource "aws_alb_target_group" "this" {
  name = "${var.name}-lb-tg"
  port = var.target_group_port
  # tfsec:ignore:AWS004
  protocol = var.protocol
  vpc_id   = var.vpc_id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = var.path
    port                = var.target_group_port
  }

  tags = {
    name = "${var.name}-lb-tg"
  }
}

resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  # tfsec:ignore:AWS004
  protocol = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.this.arn
  }
}

resource "aws_alb_listener_rule" "this" {
  listener_arn = aws_alb_listener.this.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.this.id
  }
  condition {
    path_pattern {
      values = var.listener_path_pattern
    }
  }

  depends_on = [aws_alb_target_group.this]
}
