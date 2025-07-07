output "rds_endpoint" {
  description = "PostgreSQL DB endpoint (hostname)"
  value       = aws_db_instance.education.address
}

output "rds_port" {
  description = "PostgreSQL DB port"
  value       = aws_db_instance.education.port
}