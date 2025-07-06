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

# module "lambda" {
#   source = "./modules/lambda"
# }

# module "api_gateway" {
#   source    = "./modules/api_gateway"
#   myregion  = var.myregion
#   accountId = var.accountId
#   invoke_arn    = module.lambda.invoke_arn
#   function_name = module.lambda.function_name
# }

module "rds" {
  source = "./modules/rds"
}