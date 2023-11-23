

resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = "${var.name}-${var.environment}-elasticache-cluster-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "elasticache-cluster-sg" {
  name        = "${var.name}-${var.environment}-elasticache-cluster-sg"
  description = "Allow inbound traffic from the load balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_cluster" "elasticache-cluster" {
  cluster_id           = "${var.name}-${var.environment}-redis-cluster"
  engine               = "redis"
  availability_zone    = var.availability_zone
  node_type            = var.node_type
  num_cache_nodes      = var.node_count
  engine_version       = var.engine_version
  parameter_group_name = var.parameter_group_name
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.elasticache_subnet_group.name
  security_group_ids   = ["${aws_security_group.elasticache-cluster-sg.id}"]
}

resource "aws_elasticache_cluster" "elasticache-cluster-mobilemax-bff" {
  cluster_id           = "${var.environment}-redis-cluster-mobilemax-bff"
  engine               = "redis"
  availability_zone    = var.availability_zone
  node_type            = var.node_type
  num_cache_nodes      = var.node_count
  engine_version       = var.engine_version
  parameter_group_name = var.parameter_group_name
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.elasticache_subnet_group.name
  security_group_ids   = ["${aws_security_group.elasticache-cluster-sg.id}"]
}

resource "aws_elasticache_cluster" "redis-products-core-service" {
  cluster_id                 = "${var.environment}-redis-products-core"
  node_type                  = "cache.t3.medium"
  num_cache_nodes            = var.node_count
  port                       = 6379
  engine                     = "redis"
  availability_zone          = var.availability_zone
  engine_version             = var.engine_version
  apply_immediately          = true
  auto_minor_version_upgrade = false
  parameter_group_name       = var.parameter_group_name
  subnet_group_name          = aws_elasticache_subnet_group.elasticache_subnet_group.name
  security_group_ids         = ["${aws_security_group.elasticache-cluster-sg.id}"]

}

