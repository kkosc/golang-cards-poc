### API GW
resource "aws_api_gateway_rest_api_policy" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "arn:aws:execute-api:eu-west-1:${local.account}:${aws_api_gateway_rest_api.main.id}/*/*/*"
        }
  ]
}
EOF
}

### DECK CREATE
resource "aws_iam_role" "deck_create_delete" {
  name = format(local.component_name.iam, "deck-create-delete")
  assume_role_policy = data.aws_iam_policy_document.deck_create_delete_assume.json
}

data "aws_iam_policy_document" "deck_create_delete_assume" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "deck_create_delete" {
  role = aws_iam_role.deck_create_delete.name
  policy_arn = aws_iam_policy.deck_create_delete.arn
}

resource "aws_iam_policy" "deck_create_delete" {
  name = format(local.component_name.iam, "deck-create-delete")
  policy = data.aws_iam_policy_document.deck_create_delete.json
}

### DECK OPERATE
resource "aws_iam_role" "deck_operate" {
  name = format(local.component_name.iam, "deck-operate")
  assume_role_policy = data.aws_iam_policy_document.deck_operate_assume.json
}

data "aws_iam_policy_document" "deck_operate_assume" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "deck_operate" {
  role = aws_iam_role.deck_operate.name
  policy_arn = aws_iam_policy.deck_operate.arn
}

resource "aws_iam_policy" "deck_operate" {
  name = format(local.component_name.iam, "deck-operate")
  policy = data.aws_iam_policy_document.deck_operate.json
}