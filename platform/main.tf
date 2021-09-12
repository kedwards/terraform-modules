resource "aws_launch_configuration" "this" {
  count = var.create ? 1 : 0

  image_id        = var.ami
  instance_type   = var.instance_type
  key_name        = var.provisioning_key
  security_groups = [var.security_groups]
  user_data       = var.user_data

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "this" {
  name               = "${var.name}-lb"
  internal           = var.internal ? true : false
  load_balancer_type = var.load_balancer_type
  security_groups    = var.alb_security_groups
  subnets            = var.app_subnets

  tags = merge(
    {
      "Name" = format("%s-aws-lb", var.name)
    },
    var.tags,
    var.alb_tags,
  )
}

resource "aws_alb_target_group" "this" {
  name     = "${var.name}-lb-tg"
  port     = var.target_group_port
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
  protocol          = var.protocol

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
      values = ["/*"]
    }
  }

  depends_on = [aws_alb_target_group.this]
}

resource "aws_autoscaling_attachment" "asg_attachment_app" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  alb_target_group_arn   = aws_alb_target_group.this.arn
}


resource "aws_autoscaling_group" "this" {
  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "ELB"

  launch_configuration = aws_launch_configuration.this[0].id
  vpc_zone_identifier  = var.app_subnets
}