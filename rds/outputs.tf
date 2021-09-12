output "db_host" {
  description = "The database host address."
  value       = aws_db_instance.this.address
}

output "db_user" {
  description = "The database username."
  value       = aws_db_instance.this.username
}

output "db_password" {
  description = "The database password."
  value       = random_string.db_password.result
}

output "db_database" {
  description = "The nme for the adatabase."
  value       = aws_db_instance.this.name
}
