# Variables coming from terraform.tfvars and Lambda Output values:
variable "myregion" {}
variable "accountId" {}
variable "invoke_arn" {}
variable "function_name" {}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "myapi"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "resource"  # This becomes part of the final API Gateway URL that clients call "https://{api_id}.execute-api.{region}.amazonaws.com/{stage}/resource"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

#General Integration for Lambda & API Gateway only for GET Method
resource "aws_api_gateway_integration" "integration_get" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.get_method.http_method # From the method, the received value will be "GET"
  integration_http_method = "POST"  # when it forwards the request to Lambda, it must send as POST
  type                    = "AWS_PROXY"  # also called Lambda Proxy Integration, so the entire request (method, headers, query params, body, etc.) is passed to the Lambda in a standard JSON format (API Gateway doesn't transform anything — it's just a data-pipe)

  uri                     = var.invoke_arn  # will use the values coming from the Lambda Outputs
}

#General IAM Permission for Lambda for GET/POST
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name  # will use the values coming from the Lambda Outputs
  principal     = "apigateway.amazonaws.com"

  # More: https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html#api-gateway-calling-api-permissions
  #source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.get_method.http_method}/${aws_api_gateway_resource.resource.path}"
  source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/dev/*/${aws_api_gateway_resource.resource.path_part}"   #Only this specific API Gateway endpoint is allowed to invoke this Lambda function for GET & POST calls as a DEV stage. It follows this pattern: ${execution_arn}/${stage}/${method}/${path_part}
}
## Inpired from Terraform Registry link: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration


#Ensuring GET Integrations exist before deploying
resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [aws_api_gateway_integration.integration_get, aws_api_gateway_method.get_method]
  rest_api_id = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_stage" "stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}