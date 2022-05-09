### DECK CREATE
resource "aws_lambda_function" "deck_create_delete" {
  filename = format(local.path.lambda, "deck-create-delete")
  function_name = format(local.component_name.lambda, "deck-create-delete")
  handler = "main"
  role = aws_iam_role.deck_create_delete.arn
  source_code_hash = filebase64sha256(format(local.path.lambda, "deck-create-delete"))
  publish = true
  description = "Create/Delete Deck object in DDB [POC]"

  memory_size = local.spec.lambda_standard.memory_size
  runtime = local.spec.lambda_standard.runtime
  timeout = local.spec.lambda_standard.timeout

  environment {
    variables = {
      DECKS_TABLE = aws_dynamodb_table.decks.name
    }
  }

  tags = {
    project = var.project_name
    stack = var.stack_name
  }
}

resource "aws_lambda_permission" "deck_create_delete_create" {
  statement_id  = "DeckCreateAllowExecFromApiGw"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deck_create_delete.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region}:${local.account}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.post_deck.http_method}${aws_api_gateway_resource.deck.path}"
}

resource "aws_lambda_permission" "deck_create_delete_delete" {
  statement_id  = "DeckDeleteAllowExecFromApiGw"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deck_create_delete.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region}:${local.account}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.delete_deck.http_method}${aws_api_gateway_resource.deck.path}"
}

### DECK OPERATE
resource "aws_lambda_function" "deck_operate" {
  filename = format(local.path.lambda, "deck-operate")
  function_name = format(local.component_name.lambda, "deck-operate")
  handler = "main"
  role = aws_iam_role.deck_operate.arn
  source_code_hash = filebase64sha256(format(local.path.lambda, "deck-operate"))
  publish = true
  description = "Operate Deck object (shuffle, deal cards, etc) [POC]"

  memory_size = local.spec.lambda_standard.memory_size
  runtime = local.spec.lambda_standard.runtime
  timeout = local.spec.lambda_standard.timeout

  environment {
    variables = {
      DECKS_TABLE = aws_dynamodb_table.decks.name
    }
  }

  tags = {
    project = var.project_name
    stack = var.stack_name
  }
}

resource "aws_lambda_permission" "deck_operate_shuffle" {
  statement_id  = "DeckOperateShuffleAllowExecFromApiGw"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deck_operate.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region}:${local.account}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.patch_deck_shuffle.http_method}${aws_api_gateway_resource.deck_shuffle.path}"
}

resource "aws_lambda_permission" "deck_operate_deal" {
  statement_id  = "DeckOperateDealAllowExecFromApiGw"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deck_operate.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region}:${local.account}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.patch_deck_deal.http_method}${aws_api_gateway_resource.deck_deal.path}"
}

resource "aws_lambda_permission" "deck_operate_get" {
  statement_id  = "DeckOperateGetAllowExecFromApiGw"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deck_operate.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region}:${local.account}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.get_deck.http_method}${aws_api_gateway_resource.deck.path}"
}
