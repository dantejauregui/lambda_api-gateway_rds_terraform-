output "rds_endpoint" {
  description = "PostgreSQL DB endpoint (hostname)"
  value       = aws_db_instance.education.address
}
output "rds_port" {
  description = "PostgreSQL DB port"
  value       = aws_db_instance.education.port
}

output "rds_sg_id" {
  value = aws_security_group.lambda.id
}
output "public_subnets" {
  value = module.vpc.public_subnets
}
output "private_subnets" {
  value = module.vpc.private_subnets
}