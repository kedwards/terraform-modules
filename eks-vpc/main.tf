locals {
  max_subnet_length = max(
    length(var.eks_private_subnets_prefix_list),
  )

  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(data.aws_availability_zones.availability_zones.names) : local.max_subnet_length
}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.eks_vpc_block
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${var.clusters_name_prefix}-vpc",
      format("kubernetes.io/cluster/%s", var.clusters_name_prefix) = "shared"
    },
    var.common_tags
  )

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

data "aws_availability_zones" "availability_zones" {}

// private

resource "aws_subnet" "eks_private_subnets" {
  count             = length(var.eks_private_subnets_prefix_list)
  cidr_block        = element(var.eks_private_subnets_prefix_list, count.index)
  vpc_id            = aws_vpc.eks_vpc.id
  availability_zone = data.aws_availability_zones.availability_zones.names[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = format("eks-private-%s-%01d", var.clusters_name_prefix, count.index),
      format("kubernetes.io/cluster/%s", var.clusters_name_prefix) = "owned",
      "kubernetes.io/role/internal-elb" = 1
    },
  )

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_route_table" "eks_private_route_tables" {
  count  =  local.max_subnet_length > 0 ? local.nat_gateway_count : 0
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = format("%s-private-rt", var.clusters_name_prefix)
  }
}

resource "aws_route" "eks_private_routes" {
  count                  = local.max_subnet_length > 0 ? local.nat_gateway_count : 0
  route_table_id         = element(aws_route_table.eks_private_route_tables.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.eks_nat_gws.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "eks_private_rt_association" {
  count          = length(var.eks_private_subnets_prefix_list)
  route_table_id = element(aws_route_table.eks_private_route_tables.*.id, count.index)
  subnet_id      = element(aws_subnet.eks_private_subnets.*.id, count.index)
}

// Public

resource "aws_subnet" "eks_public_subnets" {
  count             = length(var.eks_public_subnets_prefix_list)
  cidr_block        = element(var.eks_public_subnets_prefix_list, count.index)
  vpc_id            = aws_vpc.eks_vpc.id
  availability_zone = data.aws_availability_zones.availability_zones.names[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = format("eks-public-%s-%01d", var.clusters_name_prefix, count.index),
      format("kubernetes.io/cluster/%s", var.clusters_name_prefix) = "owned",
      "kubernetes.io/role/internal-elb" = 1
    },
  )

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_route_table" "eks_public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = merge(
    {
      Name = format("%s-public-rt", var.clusters_name_prefix)
    },
    var.common_tags
  )
}

resource "aws_route" "eks_public_route" {
  route_table_id         = aws_route_table.eks_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "eks_public_rt_association" {
  count          = length(var.eks_public_subnets_prefix_list)
  route_table_id = aws_route_table.eks_public_route_table.id
  subnet_id      = element(aws_subnet.eks_public_subnets.*.id, count.index)
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = merge(
    {
      Name = format("%s-igw", var.clusters_name_prefix)
    },
    var.common_tags
  )
}

resource "aws_nat_gateway" "eks_nat_gws" {
  count         = local.nat_gateway_count
  allocation_id = element(aws_eip.eks_nat_ips.*.id, count.index)
  subnet_id     = element(aws_subnet.eks_public_subnets.*.id, count.index)
  depends_on    = [aws_internet_gateway.eks_igw]

  tags = merge(
    {
      Name = format("%s-ngw", var.clusters_name_prefix)
    },
    var.common_tags
  )
}

resource "aws_eip" "eks_nat_ips" {
  count = local.nat_gateway_count
  vpc   = true

  tags = merge(
    {
      Name = format("%s-eip-ngw", var.clusters_name_prefix)
    },
    var.common_tags
  )
}