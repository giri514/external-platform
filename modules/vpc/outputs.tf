output "id" {
  value = aws_vpc.default.id
}

output "public_subnets" {
  value = aws_subnet.public_primary
}

output "private_subnets" {
  value = aws_subnet.private_primary
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds_subnet_group.name
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "availability_zones" {
  value = var.availability_zones
}
