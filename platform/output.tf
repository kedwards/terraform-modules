output "dns_name" {
  description = "The dns name of the load balancer"
  value       = concat(aws_lb.this.*.dns_name, [""])[0]
}