resource "aws_dynamodb_table" "decks" {
  name = format(local.component_name.ddb_table, "decks")
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "User"
  range_key = "CreatedAt"

  attribute {
    name = "User"
    type = "S"
  }

  attribute {
    name = "CreatedAt"
    type = "N"
  }
}