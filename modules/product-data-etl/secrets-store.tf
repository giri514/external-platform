data "aws_secretsmanager_secret_version" "product-etl" {
  secret_id = "product-etl"
}

data "aws_secretsmanager_secret_version" "branch-data" {
  secret_id = "branch-data"
}

data "aws_secretsmanager_secret_version" "category-data" {
  secret_id = "category-data"
}
