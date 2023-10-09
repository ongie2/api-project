
output "lambda_function_name" {
  value = aws_lambda_function.StoreTransactionHandler.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.StoreTransactionHandler.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.StoreTransactionHandler.invoke_arn
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.transaction_apigw.id
}

output "api_gateway_url" {
  value = aws_api_gateway_deployment.transaction_apigw_deployment.invoke_url
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.main_api_gw.name
}

output "list_transactions_function_arn" {
  value = aws_lambda_function.ListTransactionsHandler.arn
}
