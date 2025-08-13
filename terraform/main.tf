terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

module "lambda" {
  source = "./modules/lambda"

  rds_public_subnets  = module.rds.public_subnets
  rds_private_subnets = module.rds.private_subnets
  rds_sg_id           = module.rds.rds_sg_id
}

module "api_gateway" {
  source = "./modules/api_gateway"

  myregion      = var.myregion
  accountId     = var.accountId
  invoke_arn    = module.lambda.invoke_arn
  function_name = module.lambda.function_name
}

module "rds" {
  source = "./modules/rds"

  postgres_password = module.secrets.postgres_password
}

module "secrets" {
  source = "./modules/secrets"

  rds_port = module.rds.rds_port
  rds_host = module.rds.rds_endpoint
}