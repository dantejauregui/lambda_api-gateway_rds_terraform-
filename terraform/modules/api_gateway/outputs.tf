output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.myregion}.amazonaws.com/${aws_api_gateway_stage.stage.stage_name}/${aws_api_gateway_resource.resource.path_part}"
}