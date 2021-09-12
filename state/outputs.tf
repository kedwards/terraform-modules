output "bucket_arn" {
  description = "The ARN of the bucket where the state files are stored."
  value       = aws_s3_bucket.this.id
}

output "bucket_name" {
  description = "The name of the bucket where the state files are stored."
  value       = aws_s3_bucket.this.id
}

output "table_arn" {
  description = "The ARN of the table used for state locking."
  value       = aws_s3_bucket.this.id
}

output "table_name" {
  description = "The name of the table used for state locking."
  value       = aws_s3_bucket.this.id
}
