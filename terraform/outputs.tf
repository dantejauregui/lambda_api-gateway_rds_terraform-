# output "api_gateway_url" {
#   description = "Base URL for the API Gateway"
#   value       = module.api_gateway.api_gateway_url
# }
output "rds_endpoint" {
  description = "PostgreSQL DB endpoint from the RDS module"
  value       = module.rds.rds_endpoint
}