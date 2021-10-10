locals {
  max_subnet_length = max(length(var.private_prefix_list))
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(data.aws_availability_zones.availability_zones.names) : local.max_subnet_length
}

/*
  VPC for our cluster.
*/
resource "aws_vpc" "k8s" {
  cidr_block           = var.vpc_block
  enable_dns_hostnames = true

  tags = merge(
    {
      Name                                                = "${var.clusters_name_prefix}",
      "kubernetes.io/cluster/${var.clusters_name_prefix}" = "shared",
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

/*
  Private network
  We create a /18 subnet for each AZ we are using.
  This gives us 16382 IPs (per subnet)
  We are using much larger subnet ranges for the private
  subnets as Pod IPs are allocated from these ranges,
  since Kubernetes  networking requires a Unique IP for each
  Pod we need lots of IPs.
*/
resource "aws_subnet" "private" {
  count             = length(var.private_prefix_list)
  cidr_block        = element(var.private_prefix_list, count.index)
  // cidr_block        = cidrsubnet(var.vpc_block, 1, count.index + 1)
  vpc_id            = aws_vpc.k8s.id
  availability_zone = data.aws_availability_zones.availability_zones.names[count.index]

  tags = merge(
    var.common_tags,
    {
      Name                                                = format("eks-private-%s-%01d", var.clusters_name_prefix, count.index),
      "kubernetes.io/cluster/${var.clusters_name_prefix}" = "owned",
      "kubernetes.io/role/internal-elb"                   = 1
    },
  )

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_route_table" "eks_private_route_tables" {
  count  = local.max_subnet_length > 0 ? local.nat_gateway_count : 0
  vpc_id = aws_vpc.k8s.id

  tags = merge(
    {
      Name = "${var.clusters_name_prefix}-private"
    },
    var.common_tags
  )
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
  count          = length(var.private_prefix_list)
  route_table_id = element(aws_route_table.eks_private_route_tables.*.id, count.index)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
}

/*
  Public network
  We create a /24 subnet for each AZ we are using.
  This gives us 251 usable IPs (per subnet) for resources we want
  to have public IP addresses like Load Balancers.
*/
resource "aws_subnet" "public" {
  count             = length(var.public_prefix_list)
  cidr_block        = element(var.public_prefix_list, count.index)
  // cidr_block       = cidrsubnet(var.vpc_block, 7, count.index)
  vpc_id            = aws_vpc.k8s.id,
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.availability_zones.names[count.index]

  tags = merge(
    var.common_tags,
    {
      Name                                               = format("eks-public-%s-%01d", var.clusters_name_prefix, count.index),
      "kubernetes.io/cluster/${var.clusters_name_prefix" = "owned",
      "kubernetes.io/role/internal-elb"                  = 1
    },
  )

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_route_table" "eks_public_route_table" {
  vpc_id = aws_vpc.k8s.id

  tags = merge(
    {
      Name = "${var.clusters_name_prefix}-public"
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
  count          = length(var.public_prefix_list)
  route_table_id = aws_route_table.eks_public_route_table.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

/*
  In order for our instances to connect to the internet
  we provision an internet gateway.
*/
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.k8s.id

  tags = merge(
    {
      Name = "${ var.clusters_name_prefix}-igw"
    },
    var.common_tags
  )
}


/*
  For instances without a Public IP address we will route traffic
  through a NAT Gateway. Setup an Elastic IP and attach it.
  We are only setting up a single NAT gateway, for simplicity.
  If the availability is important you might add another in a
  second availability zone.
*/
resource "aws_nat_gateway" "eks_nat_gws" {
  count         = local.nat_gateway_count
  allocation_id = element(aws_eip.eks_nat_ips.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.eks_igw]

  tags = merge(
    {
      Name = format("%s-ngw", var.clusters_name_prefix)
    },
    var.common_tags
  )
}

resource "aws_eip" "nat" {
  count = local.nat_gateway_count
  vpc   = true

  tags = merge(
    {
      Name = "${var.clusters_name_prefix}-ngw",
    },
    var.common_tags
  )
}