variable "environment" {
  type        = string
  description = "Execution environment"
}
variable "node_count" {
  type        = number
  description = "Number of nodes in the cluster"
  default     = 1
}
variable "node_type" {
  type        = string
  description = "The ec2 instance class"
  default     = "cache.t3.micro"
}
variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}
variable "name" {
  type        = string
  description = "Name of the cluster"
}

variable "engine_version" {
  type        = string
  description = "The engine version to use"
  default     = "6.2"
}

variable "parameter_group_name" {
  type        = string
  description = "The name of the parameter group to associate with this replication group"
  default     = "default.redis6.x"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The VPC Subnet IDs for the cache subnet group"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC CIDR"
}
