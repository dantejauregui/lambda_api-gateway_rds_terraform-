variable "rds_port" {}
variable "rds_host" {}

# Generate a secure random alphanumeric password
resource "random_password" "postgres_password" {
  length  = 24    # Total password length: 24 characters
  special = false # Exclude special characters (alphanumeric only for compatibility)
}

# Define a new Secrets Manager secret to store RDS credentials:
resource "aws_secretsmanager_secret" "pg_secrets" {
  name = "postgres-credentials"
  recovery_window_in_days = 0  # Force immediate deletion when "terraform destroy" (Use it only in dev/test environments, No for PRODUCTION!)
}

resource "aws_secretsmanager_secret_version" "pg_secrets_version" {
  secret_id     = aws_secretsmanager_secret.pg_secrets.id

  # Encode credentials as a JSON string and store as the secret value
  secret_string = jsonencode({
    password = random_password.postgres_password.result, # Dynamic, securely generated password
    port = var.rds_port,
    host = var.rds_host
  })
}
