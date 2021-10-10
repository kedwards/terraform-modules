output "security_group" {
  value = aws_security_group.control_plane.id
}

output "ca" {
  value = aws_eks_cluster.control_plane.certificate_authority[0].data
}

output "endpoint" {
  value = aws_eks_cluster.control_plane.endpoint
}
