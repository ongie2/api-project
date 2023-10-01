##############
# API Gateway#
##############
resource "aws_api_gateway_rest_api" "transaction_apigw" {
  name        = "transaction_apigw"
  description = "Transaction API Gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "transaction" {
  rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
  parent_id   = aws_api_gateway_rest_api.transaction_apigw.root_resource_id
  path_part   = "transaction"
}

resource "aws_api_gateway_resource" "list_transactions" {
  rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
  parent_id   = aws_api_gateway_rest_api.transaction_apigw.root_resource_id
  path_part   = "list_transactions"
}

resource "aws_api_gateway_method" "storetransaction" {
  rest_api_id   = aws_api_gateway_rest_api.transaction_apigw.id
  resource_id   = aws_api_gateway_resource.transaction.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "list_transactions" {
  rest_api_id   = aws_api_gateway_rest_api.transaction_apigw.id
  resource_id   = aws_api_gateway_resource.list_transactions.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "storetransaction-lambda" {
  rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
  resource_id = aws_api_gateway_resource.transaction.id
  http_method = aws_api_gateway_method.storetransaction.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  uri = aws_lambda_function.StoreTransactionHandler.invoke_arn
}

resource "aws_api_gateway_integration" "list_transactions-lambda" {
  rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
  resource_id = aws_api_gateway_resource.list_transactions.id
  http_method = aws_api_gateway_method.list_transactions.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"

  uri = aws_lambda_function.ListTransactionsHandler.invoke_arn
}

resource "aws_lambda_permission" "apigw-StoreTransactionHandler" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.StoreTransactionHandler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.transaction_apigw.execution_arn}/*/POST/transaction"
}

resource "aws_lambda_permission" "apigw-ListTransactionsHandler" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ListTransactionsHandler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.transaction_apigw.execution_arn}/*/GET/list_transactions"
}

resource "aws_cloudwatch_log_group" "main_api_gw" {
  name = "/aws/api-gw/${aws_api_gateway_rest_api.transaction_apigw.name}"
  retention_in_days = 14
}


resource "aws_api_gateway_deployment" "transaction_apigw_deployment" {
  depends_on = [
    aws_api_gateway_method.storetransaction,
    aws_api_gateway_method.list_transactions,
    aws_api_gateway_integration.storetransaction-lambda,
    aws_api_gateway_integration.list_transactions-lambda,
  ]
  rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
  stage_name  = "Dev" 
}
