data "aws_iam_policy_document" "deck_create_delete" {
  statement {
    effect = "Allow"
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
  //put/get parameters from SecretStore, just in case
  statement {
    effect = "Allow"
    actions = ["ssm:PutParameter", "ssm:GetParameter", "ssm:GetParameters"]
    resources = ["arn:aws:ssm:${local.region}:${local.account}:parameter/go-test*"]
  }
  //decrypt SSM parameters, just in case
  statement {
    effect = "Allow"
    actions = ["kms:Decrypt"]
    resources = ["arn:aws:kms:${local.region}:${local.account}:alias/aws/ssm"]
  }
  statement {
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::*"
    ]
  }
  statement {
    effect = "Allow"
    actions = ["s3:*Object*"]
    resources = [
      "arn:aws:s3:::*/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:ConditionCheckItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTimeToLive"]
    resources = [aws_dynamodb_table.decks.arn]
  }
}

data "aws_iam_policy_document" "deck_operate" {
  statement {
    effect = "Allow"
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
  //put/get parameters from SecretStore, just in case
  statement {
    effect = "Allow"
    actions = ["ssm:PutParameter", "ssm:GetParameter", "ssm:GetParameters"]
    resources = ["arn:aws:ssm:${local.region}:${local.account}:parameter/go-test*"]
  }
  //decrypt SSM parameters, just in case
  statement {
    effect = "Allow"
    actions = ["kms:Decrypt"]
    resources = ["arn:aws:kms:${local.region}:${local.account}:alias/aws/ssm"]
  }
  statement {
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::*"
    ]
  }
  statement {
    effect = "Allow"
    actions = ["s3:*Object*"]
    resources = [
      "arn:aws:s3:::*/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:ConditionCheckItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTimeToLive"]
    resources = [aws_dynamodb_table.decks.arn]
  }
}
