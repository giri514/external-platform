###################
#    Elastic IP   #
###################
resource "aws_eip" "nat" {
  count = length(var.private_subnets)
  vpc   = true

  tags = {
    Name        = "${var.name}-${var.environment}-eip-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }
}

###################
#   NAT Gateway   #
###################
resource "aws_nat_gateway" "default" {
  count         = length(var.private_subnets)
  allocation_id = element(aws_eip.nat[*].id, count.index)
  subnet_id     = element(aws_subnet.public_primary[*].id, count.index)
  depends_on    = [aws_internet_gateway.default]

  tags = {
    Name                    = "${var.name}-${var.environment}-nat-${format("%03d", count.index + 1)}"
    Environment             = var.environment
    Function                = "Application"
    "Contact Email Address" = var.contact_emails
  }
}
