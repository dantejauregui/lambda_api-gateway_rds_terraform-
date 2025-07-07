output "postgres_password" {
  description = "PostgreSQL password"
  value       = random_password.postgres_password.result #this way only will work cause is complicated to share "Secrets values" between modules
}