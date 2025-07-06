output "rds_endpoint" {
  description = "PostgreSQL DB endpoint (hostname)"
  value       = aws_db_instance.education.endpoint
}