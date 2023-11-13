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

resource "aws_api_gateway_method" "deletetransaction" {
  rest_api_id   = aws_api_gateway_rest_api.transaction_apigw.id
  resource_id   = aws_api_gateway_resource.transaction.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "updatetransaction" {
  rest_api_id   = aws_api_gateway_rest_api.transaction_apigw.id
  resource_id   = aws_api_gateway_resource.transaction.id
  http_method   = "PUT"  # or "PATCH" depending on your API design
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

resource "aws_api_gateway_integration" "deletetransaction-lambda" {
  rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
  resource_id = aws_api_gateway_resource.transaction.id
  http_method = aws_api_gateway_method.deletetransaction.http_method
  integration_http_method = "POST"  # Lambda uses POST for all invocations
  type                    = "AWS_PROXY"
  uri = aws_lambda_function.DeleteTransactionHandler.invoke_arn
}

resource "aws_api_gateway_integration" "updatetransaction-lambda" {
  rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
  resource_id = aws_api_gateway_resource.transaction.id
  http_method = aws_api_gateway_method.updatetransaction.http_method
  integration_http_method = "POST"  # Lambda uses POST for all invocations
  type                    = "AWS_PROXY"
  uri = aws_lambda_function.UpdateTransactionHandler.invoke_arn
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

resource "aws_lambda_permission" "apigw-DeleteTransactionHandler" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.DeleteTransactionHandler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.transaction_apigw.execution_arn}/*/DELETE/transaction"
}

resource "aws_lambda_permission" "apigw-UpdateTransactionHandler" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.UpdateTransactionHandler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.transaction_apigw.execution_arn}/*/PUT/transaction"  # or PATCH
}

resource "aws_cloudwatch_log_group" "main_api_gw" {
  name              = "/aws/api-gw/${aws_api_gateway_rest_api.transaction_apigw.name}"
  retention_in_days = 14
}

resource "aws_api_gateway_deployment" "transaction_apigw_deployment" {
  depends_on = [
    aws_api_gateway_method.storetransaction,
    aws_api_gateway_method.list_transactions,
    aws_api_gateway_method.deletetransaction,
    aws_api_gateway_method.updatetransaction,
    aws_api_gateway_integration.storetransaction-lambda,
    aws_api_gateway_integration.list_transactions-lambda,
    aws_api_gateway_integration.deletetransaction-lambda,
    aws_api_gateway_integration.updatetransaction-lambda,
  ]
  rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
  stage_name  = "Dev"
}


# resource "aws_api_gateway_rest_api" "transaction_apigw" {
#   name        = "transaction_apigw"
#   description = "Transaction API Gateway"
#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

# resource "aws_api_gateway_resource" "transaction" {
#   rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
#   parent_id   = aws_api_gateway_rest_api.transaction_apigw.root_resource_id
#   path_part   = "transaction"
# }

# resource "aws_api_gateway_resource" "list_transactions" {
#   rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
#   parent_id   = aws_api_gateway_rest_api.transaction_apigw.root_resource_id
#   path_part   = "list_transactions"
# }

# resource "aws_api_gateway_method" "storetransaction" {
#   rest_api_id   = aws_api_gateway_rest_api.transaction_apigw.id
#   resource_id   = aws_api_gateway_resource.transaction.id
#   http_method   = "POST"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_method" "list_transactions" {
#   rest_api_id   = aws_api_gateway_rest_api.transaction_apigw.id
#   resource_id   = aws_api_gateway_resource.list_transactions.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "storetransaction-lambda" {
#   rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
#   resource_id = aws_api_gateway_resource.transaction.id
#   http_method = aws_api_gateway_method.storetransaction.http_method

#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"

#   uri = aws_lambda_function.StoreTransactionHandler.invoke_arn
# }

# resource "aws_api_gateway_integration" "list_transactions-lambda" {
#   rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
#   resource_id = aws_api_gateway_resource.list_transactions.id
#   http_method = aws_api_gateway_method.list_transactions.http_method

#   integration_http_method = "GET"
#   type                    = "AWS_PROXY"

#   uri = aws_lambda_function.ListTransactionsHandler.invoke_arn
# }

# resource "aws_lambda_permission" "apigw-StoreTransactionHandler" {
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.StoreTransactionHandler.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.transaction_apigw.execution_arn}/*/POST/transaction"
# }

# resource "aws_lambda_permission" "apigw-ListTransactionsHandler" {
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.ListTransactionsHandler.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.transaction_apigw.execution_arn}/*/GET/list_transactions"
# }

# resource "aws_cloudwatch_log_group" "main_api_gw" {
#   name              = "/aws/api-gw/${aws_api_gateway_rest_api.transaction_apigw.name}"
#   retention_in_days = 14
# }


# resource "aws_api_gateway_deployment" "transaction_apigw_deployment" {
#   depends_on = [
#     aws_api_gateway_method.storetransaction,
#     aws_api_gateway_method.list_transactions,
#     aws_api_gateway_integration.storetransaction-lambda,
#     aws_api_gateway_integration.list_transactions-lambda,
#   ]
#   rest_api_id = aws_api_gateway_rest_api.transaction_apigw.id
#   stage_name  = "Dev"
# }
