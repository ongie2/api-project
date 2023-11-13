output "delete_transaction_function_name" {
  value = aws_lambda_function.DeleteTransactionHandler.function_name
}

output "delete_transaction_function_arn" {
  value = aws_lambda_function.DeleteTransactionHandler.arn
}

output "delete_transaction_invoke_arn" {
  value = aws_lambda_function.DeleteTransactionHandler.invoke_arn
}

output "update_transaction_function_name" {
  value = aws_lambda_function.UpdateTransactionHandler.function_name
}

output "update_transaction_function_arn" {
  value = aws_lambda_function.UpdateTransactionHandler.arn
}

output "update_transaction_invoke_arn" {
  value = aws_lambda_function.UpdateTransactionHandler.invoke_arn
}
