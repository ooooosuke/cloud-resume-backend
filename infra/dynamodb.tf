resource "aws_dynamodb_table" "visitor_stats" {
  name         = "${var.project_name}-table-${var.env}-visitor-stats"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}