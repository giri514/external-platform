resource "aws_instance" "bastion" { #tfsec:ignore:aws-ec2-enforce-http-token-imds tfsec:ignore:aws-ec2-enable-at-rest-encryption
  ami                         = "ami-0947d2ba12ee1ff75"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = var.public_subnet
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = var.bastion_key_pair_name

  lifecycle {
    ignore_changes = [
    ]
  }

  tags = {
    "Name"                  = "EC2-${var.environment}-bastion-host"
    "Group Owner"           = "Reece"
    "Contact Email Address" = var.contact_emails
    "Description"           = "A jump box used to securely access the private networks"
    "Environment"           = "external-${var.environment}"
    "OS"                    = "linux"
    "Subnet"                = "public"
    "Function"              = "debugging"
    "Run Status"            = "24"
    "Terminate Date"        = "n/a"
    "Instance Type"         = "t2.medium"
    "Maintenance Window"    = "n/a"
  }
}

resource "aws_instance" "private-host" { #tfsec:ignore:aws-ec2-enforce-http-token-imds tfsec:ignore:aws-ec2-enable-at-rest-encryption
  ami                    = "ami-0947d2ba12ee1ff75"
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet
  vpc_security_group_ids = [aws_security_group.private_host_sg.id]
  key_name               = var.private_host_key_pair_name

  lifecycle {
    ignore_changes = [
    ]
  }

  tags = {
    "Name"                  = "EC2-${var.environment}-private-host"
    "Group Owner"           = "Reece"
    "Contact Email Address" = var.contact_emails
    "Description"           = "A server within the private networks"
    "Environment"           = "external-${var.environment}"
    "OS"                    = "linux"
    "Subnet"                = "private"
    "Function"              = "debugging"
    "Run Status"            = "24"
    "Terminate Date"        = "n/a"
    "Instance Type"         = "t2.micro"
    "Maintenance Window"    = "n/a"
  }
}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion_security_group"
  vpc_id = var.vpc

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-ingress-sgr
  }

  ingress {
    protocol    = "tcp"
    from_port   = 1433
    to_port     = 1433
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-ingress-sgr
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-egress-sgr
  }

  tags = {}
}

resource "aws_security_group" "private_host_sg" {
  name   = "private_host_security_group"
  vpc_id = var.vpc

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {}
}
