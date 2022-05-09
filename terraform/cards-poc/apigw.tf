##############
# APIGW CORE #
##############
resource "aws_api_gateway_rest_api" "main" {
  name = format(local.component_name.apigw, "main")

  tags = {
    project = var.project_name
    stack = var.stack_name
  }
}

//dirty and brittle hack to force apigw deployment resource to be deployed as last, for poc purposes only
resource "null_resource" "wait_for_all_resources" {
  triggers = {
    timestamp = timestamp()
  }
  provisioner "local-exec" {
    command     = "sleep 60"
  }
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(file("${path.module}/apigw.tf"))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [null_resource.wait_for_all_resources]
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "api"

  access_log_settings {
    destination_arn = "arn:aws:logs:eu-west-1:${local.account}:log-group:/apigateway/access-logs/${aws_api_gateway_rest_api.main.name}"
    format = jsonencode({
      caller = "$context.identity.caller"
      httpMethod = "$context.httpMethod"
      ip = "$context.identity.sourceIp"
      protocol = "$context.protocol"
      requestId = "$context.requestId"
      requestTime = "$context.requestTime"
      resourcePath = "$context.resourcePath"
      responseLength = "$context.responseLength"
      status = "$context.status"
      user = "$context.identity.user"
    })
  }

  tags = {
    project = var.project_name
    stack = var.stack_name
  }
}

resource "aws_api_gateway_domain_name" "cards" {
  domain_name = var.api_dns_name
  regional_certificate_arn = var.api_tls_cert_arn
  security_policy = "TLS_1_2"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    project = var.project_name
    stack = var.stack_name
  }
}

resource "aws_api_gateway_base_path_mapping" "main" {
  api_id = aws_api_gateway_rest_api.main.id
  stage_name = aws_api_gateway_stage.main.stage_name
  domain_name = aws_api_gateway_domain_name.cards.domain_name
  base_path = "api"
}

#############
# RESOURCES #
#############

## DECK
resource "aws_api_gateway_resource" "deck" {
  parent_id = aws_api_gateway_rest_api.main.root_resource_id
  path_part = "deck"
  rest_api_id = aws_api_gateway_rest_api.main.id
}

## DECK SHUFFLE -> DECK OPERATE
resource "aws_api_gateway_resource" "deck_shuffle" {
  parent_id = aws_api_gateway_resource.deck.id
  path_part = "shuffle"
  rest_api_id = aws_api_gateway_rest_api.main.id
}

## DECK DEAL -> DECK OPERATE
resource "aws_api_gateway_resource" "deck_deal" {
  parent_id = aws_api_gateway_resource.deck.id
  path_part = "deal"
  rest_api_id = aws_api_gateway_rest_api.main.id
}

################
# REST METHODS #
################
resource "aws_api_gateway_method" "post_deck" {
  http_method = "POST"
  authorization = "NONE"
  resource_id = aws_api_gateway_resource.deck.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  api_key_required = false
}

resource "aws_api_gateway_method" "get_deck" {
  http_method = "GET"
  authorization = "NONE"
  resource_id = aws_api_gateway_resource.deck.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  api_key_required = false
  request_parameters = {
    "method.request.querystring.user" = true
    "method.request.querystring.created-at" = true
  }
}

resource "aws_api_gateway_method" "delete_deck" {
  http_method = "DELETE"
  authorization = "NONE"
  resource_id = aws_api_gateway_resource.deck.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  api_key_required = false
}

resource "aws_api_gateway_method" "patch_deck_shuffle" {
  http_method = "PATCH"
  authorization = "NONE"
  resource_id = aws_api_gateway_resource.deck_shuffle.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  api_key_required = false
}

resource "aws_api_gateway_method" "patch_deck_deal" {
  http_method = "PATCH"
  authorization = "NONE"
  resource_id = aws_api_gateway_resource.deck_deal.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  api_key_required = false
}

################
# INTEGRATIONS #
################
resource "aws_api_gateway_integration" "post_deck" {
  http_method = aws_api_gateway_method.post_deck.http_method
  resource_id = aws_api_gateway_resource.deck.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.deck_create_delete.invoke_arn
}

resource "aws_api_gateway_integration" "delete_deck" {
  http_method = aws_api_gateway_method.delete_deck.http_method
  resource_id = aws_api_gateway_resource.deck.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.deck_create_delete.invoke_arn
}

resource "aws_api_gateway_integration" "get_deck" {
  http_method = aws_api_gateway_method.get_deck.http_method
  resource_id = aws_api_gateway_resource.deck.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.deck_operate.invoke_arn

  request_parameters = {
    "integration.request.querystring.User" = "method.request.querystring.user"
    "integration.request.querystring.CreatedAt" = "method.request.querystring.created-at"
  }
}

resource "aws_api_gateway_integration" "patch_deck_shuffle" {
  http_method = aws_api_gateway_method.patch_deck_shuffle.http_method
  resource_id = aws_api_gateway_resource.deck_shuffle.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.deck_operate.invoke_arn
}

resource "aws_api_gateway_integration" "patch_deck_deal" {
  http_method = aws_api_gateway_method.patch_deck_deal.http_method
  resource_id = aws_api_gateway_resource.deck_deal.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.deck_operate.invoke_arn
}

##################
# BASE RESPONSES #
##################
resource "aws_api_gateway_model" "response_200" {
  content_type = "application/json"
  name = "response200"
  rest_api_id = aws_api_gateway_rest_api.main.id
  schema = <<EOF
{
  "type": "object"
}
EOF
}

resource "aws_api_gateway_model" "response_400" {
  content_type = "application/json"
  name = "response400"
  rest_api_id = aws_api_gateway_rest_api.main.id
  schema = <<EOF
{
  "type": "object"
}
EOF
}

resource "aws_api_gateway_model" "response_500" {
  content_type = "application/json"
  name = "response500"
  rest_api_id = aws_api_gateway_rest_api.main.id
  schema = <<EOF
{
  "type": "object"
}
EOF
}

#############
# RESPONSES #
#############

## DECK CREATE
resource "aws_api_gateway_method_response" "post_deck_create_response_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck.id
  http_method = aws_api_gateway_method.post_deck.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.response_200.name
  }
}

resource "aws_api_gateway_method_response" "post_deck_create_response_400" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck.id
  http_method = aws_api_gateway_method.post_deck.http_method
  status_code = "400"
  response_models = {
    "application/json" = aws_api_gateway_model.response_400.name
  }
}

resource "aws_api_gateway_method_response" "post_deck_create_response_500" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck.id
  http_method = aws_api_gateway_method.post_deck.http_method
  status_code = "500"
  response_models = {
    "application/json" = aws_api_gateway_model.response_500.name
  }
}

## DECK DELETE
resource "aws_api_gateway_method_response" "delete_deck_create_response_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck.id
  http_method = aws_api_gateway_method.delete_deck.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.response_200.name
  }
}

resource "aws_api_gateway_method_response" "delete_deck_create_response_400" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck.id
  http_method = aws_api_gateway_method.delete_deck.http_method
  status_code = "400"
  response_models = {
    "application/json" = aws_api_gateway_model.response_400.name
  }
}

resource "aws_api_gateway_method_response" "delete_deck_create_response_500" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck.id
  http_method = aws_api_gateway_method.delete_deck.http_method
  status_code = "500"
  response_models = {
    "application/json" = aws_api_gateway_model.response_500.name
  }
}

## DECK GET
resource "aws_api_gateway_method_response" "get_deck_response_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck.id
  http_method = aws_api_gateway_method.get_deck.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.response_200.name
  }
}

resource "aws_api_gateway_method_response" "get_deck_response_400" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck.id
  http_method = aws_api_gateway_method.get_deck.http_method
  status_code = "400"
  response_models = {
    "application/json" = aws_api_gateway_model.response_400.name
  }
}

resource "aws_api_gateway_method_response" "get_deck_response_500" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck.id
  http_method = aws_api_gateway_method.get_deck.http_method
  status_code = "500"
  response_models = {
    "application/json" = aws_api_gateway_model.response_500.name
  }
}

## DECK OPERATE SHUFFLE
resource "aws_api_gateway_method_response" "patch_deck_operate_shuffle_response_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck_shuffle.id
  http_method = aws_api_gateway_method.patch_deck_shuffle.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.response_200.name
  }
}

resource "aws_api_gateway_method_response" "patch_deck_operate_shuffle_response_400" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck_shuffle.id
  http_method = aws_api_gateway_method.patch_deck_shuffle.http_method
  status_code = "400"
  response_models = {
    "application/json" = aws_api_gateway_model.response_400.name
  }
}

resource "aws_api_gateway_method_response" "patch_deck_operate_shuffle_response_500" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck_shuffle.id
  http_method = aws_api_gateway_method.patch_deck_shuffle.http_method
  status_code = "500"
  response_models = {
    "application/json" = aws_api_gateway_model.response_500.name
  }
}

## DECK OPERATE DEAL
resource "aws_api_gateway_method_response" "patch_deck_operate_deal_response_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck_deal.id
  http_method = aws_api_gateway_method.patch_deck_deal.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.response_200.name
  }
}

resource "aws_api_gateway_method_response" "patch_deck_operate_deal_response_400" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck_deal.id
  http_method = aws_api_gateway_method.patch_deck_deal.http_method
  status_code = "400"
  response_models = {
    "application/json" = aws_api_gateway_model.response_400.name
  }
}

resource "aws_api_gateway_method_response" "patch_deck_operate_deal_response_500" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.deck_deal.id
  http_method = aws_api_gateway_method.patch_deck_deal.http_method
  status_code = "500"
  response_models = {
    "application/json" = aws_api_gateway_model.response_500.name
  }
}