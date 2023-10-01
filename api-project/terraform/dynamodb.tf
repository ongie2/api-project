################
# DynamoDB Table
################
resource "aws_dynamodb_table" "transaction_table" {
  name         = "TRANSACTION"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "transaction_id"

  attribute {
    name = "transaction_id"
    type = "S"
  }

  attribute {
    name = "category"
    type = "S"
  }

  attribute {
    name = "product_rating"
    type = "N"
  }

  global_secondary_index {
    name            = "TransactionCategoryRatingIndex"
    hash_key        = "category"
    range_key       = "product_rating"
    projection_type = "ALL"
  }
}
