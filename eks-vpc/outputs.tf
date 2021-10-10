output "eks_cluster_vpc_id" {
  value = aws_vpc.k8s.id
}

output "eks_private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "eks_public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "eks_nat_ips" {
  value = aws_eip.nat.*.public_ip
}
