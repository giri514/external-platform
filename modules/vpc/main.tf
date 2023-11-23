#######################
#  VPC Configuration  #
#######################
resource "aws_vpc" "default" { #tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                                   = "${var.name}-${var.environment}-vpc"
    Environment                                            = var.environment
    "kubernetes.io/cluster/${var.name}-${var.environment}" = "shared"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name                    = "${var.name}-${var.environment}-igw"
    Environment             = var.environment
    "Group Owner"           = "Infrastructure / Network"
    "VPC Name"              = "${var.name}-${var.environment}-vpc}"
    "Contact Email Address" = var.contact_emails
  }
}
