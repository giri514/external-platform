# ###################
# #  Public Subnet  #
# ###################
resource "aws_subnet" "public_primary" {
  vpc_id = aws_vpc.default.id

  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true #tfsec:ignore:aws-ec2-no-public-ip-subnet

  tags = {
    Name                                                   = "${var.name}-${var.environment}-public-subnet-${format("%03d", count.index + 1)}"
    Environment                                            = var.environment
    "kubernetes.io/cluster/${var.name}-${var.environment}" = "shared"
    "kubernetes.io/role/elb"                               = "1"
  }
}

resource "aws_route_table" "public_primary" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name        = "${var.name}-${var.environment}-routing-table-public"
    Environment = var.environment
  }
}

resource "aws_route" "public_primary" {
  route_table_id         = aws_route_table.public_primary.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "public_primary" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public_primary[*].id, count.index)
  route_table_id = aws_route_table.public_primary.id
}

# ###################################
# #  Private Subnet - For EKS Pods  #
# ###################################

resource "aws_subnet" "private_primary" {
  vpc_id = aws_vpc.default.id

  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.private_subnets)

  tags = {
    Name                                                   = "${var.name}-${var.environment}-private-subnet-${format("%03d", count.index + 1)}"
    Environment                                            = var.environment
    "kubernetes.io/cluster/${var.name}-${var.environment}" = "shared"
    "kubernetes.io/role/external-elb"                      = "1"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table" "private_primary" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.default.id

  tags = {
    Name        = "${var.name}-${var.environment}-routing-table-private-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }
}

resource "aws_route" "private_primary" {
  count                  = length(compact(var.private_subnets))
  route_table_id         = element(aws_route_table.private_primary[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route_table_association" "private_primary" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private_primary[*].id, count.index)
  route_table_id = element(aws_route_table.private_primary[*].id, count.index)
}

####################
#  Subnet Groups  #
####################
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds_subnet_group_${var.environment}"
  description = "RDS subnet group ${var.environment}"
  subnet_ids  = aws_subnet.private_primary[*].id
}
