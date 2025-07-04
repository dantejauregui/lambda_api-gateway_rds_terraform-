# IAM role for Lambda execution (this is a Resource-based policy (so uses "Principal" or inline-policy focused in a specific aws resoruces), and is NOT an identity-based policy that can be assigned to many aws resources)
data "aws_iam_policy_document" "trust_policy_lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy_lambda_assume_role.json
}
data "aws_iam_policy_document" "execution_policy_lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "lambda_logging" {
  name   = "lambda_logging"
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.execution_policy_lambda_logging.json
}
   

resource "aws_lambda_function" "hello_lambda" {
  filename         = "lambda.zip"
  function_name    = "MyHelloWorldLambda"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.lambda_handler"
  source_code_hash = filebase64sha256("lambda.zip")
  timeout          = 10
  runtime          = "python3.9"

  environment {
    variables = {
      ENVIRONMENT = "dev"
      LOG_LEVEL   = "info"
    }
  }
}