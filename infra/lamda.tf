# Lambda用IAMロール
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-role-${var.env}-lambda-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# DynamoDBへのアクセス権限
resource "aws_iam_role_policy" "dynamodb_policy" {
  name = "lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "dynamodb:GetItem",
        "dynamodb:UpdateItem"
      ]
      Effect   = "Allow"
      Resource = "${aws_dynamodb_table.visitor_stats.arn}"
    }]
  })
}

# Lambda関数の定義
resource "aws_lambda_function" "visitor_counter" {
  filename      = "lambda_function_payload.zip" # CI/CDで生成
  function_name = "${var.project_name}-lambda-${var.env}-visitor-counter"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitor_stats.name
    }
  }
}

# API Gatewayからの呼び出し許可
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
}