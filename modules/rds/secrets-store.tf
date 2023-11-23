data "aws_secretsmanager_secret_version" "postgres-db" {
  secret_id = "postgres-db"
}
