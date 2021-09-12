#
# Security group
#
resource "aws_security_group" "this" {
  count = var.create ? 1 : 0

  description = var.description
  name        = var.name
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-sg", var.name)
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

#
# Security group INGRESS rules
#
resource "aws_security_group_rule" "ingress_rules" {
  count = var.create ? length(var.ingress_rules) : 0

  cidr_blocks       = var.ingress_rules[count.index][4]
  description       = var.ingress_rules[count.index][3]
  from_port         = var.ingress_rules[count.index][0]
  ipv6_cidr_blocks  = var.ingress_ipv6_cidr_blocks
  protocol          = var.ingress_rules[count.index][2]
  security_group_id = aws_security_group.this[0].id
  to_port           = var.ingress_rules[count.index][1]
  type              = "ingress"
}

#
# Security group EGRESS rules
#
resource "aws_security_group_rule" "egress_rules" {
  count = var.create ? length(var.egress_rules) : 0

  cidr_blocks       = var.egress_rules[count.index][4]
  description       = var.egress_rules[count.index][3]
  from_port         = var.egress_rules[count.index][0]
  ipv6_cidr_blocks  = var.egress_ipv6_cidr_blocks
  protocol          = var.egress_rules[count.index][2]
  security_group_id = aws_security_group.this[0].id
  to_port           = var.egress_rules[count.index][1]
  type              = "egress"
}
