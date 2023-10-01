resource "aws_iam_role" "TransactionLambdaRole" {
  name               = "TransactionLambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "template_file" "transactionlambdapolicy" {
  template = file("${path.module}/policy.json")
}

resource "aws_iam_policy" "TransactionLambdaPolicy" {
  name        = "TransactionLambdaPolicy"
  path        = "/"
  description = "IAM policy for Transaction lambda functions"
  policy      = data.template_file.transactionlambdapolicy.rendered
}

resource "aws_iam_role_policy_attachment" "TransactionLambdaRolePolicy" {
  role       = aws_iam_role.TransactionLambdaRole.name
  policy_arn = aws_iam_policy.TransactionLambdaPolicy.arn
}

data "archive_file" "lambda_zip_store" {
  type        = "zip"
  source_dir  = "../lambda"
  output_path = "../lambda/StoreTransactionHandler.zip"
}

data "archive_file" "lambda_zip_list" {
  type        = "zip"
  source_dir  = "../lambda"
  output_path = "../lambda/ListTransactionsHandler.zip"
}

resource "aws_lambda_function" "StoreTransactionHandler" {
  function_name = "StoreTransactionHandler"
  filename      =  data.archive_file.lambda_zip_store.output_path
  handler       = "StoreTransactionHandler.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      REGION           = "us-east-1"
      TRANSACTION_TABLE = aws_dynamodb_table.transaction_table.name
    }
  }

  role        = aws_iam_role.TransactionLambdaRole.arn
  timeout     = "5"
  memory_size = "128"
}

resource "aws_lambda_function" "ListTransactionsHandler" {
  function_name = "ListTransactionsHandler"
  filename      =  data.archive_file.lambda_zip_list.output_path
  handler       = "ListTransactionsHandler.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      REGION           = "us-east-1"
      TRANSACTION_TABLE = aws_dynamodb_table.transaction_table.name
    }
  }

  role        = aws_iam_role.TransactionLambdaRole.arn
  timeout     = "5"
  memory_size = "128"
}

resource "aws_cloudwatch_log_group" "lambda_log_group_store" {
  name = "/aws/lambda/${aws_lambda_function.StoreTransactionHandler.function_name}"

  retention_in_days = 14
}
