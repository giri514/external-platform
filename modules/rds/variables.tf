variable "environment" {
  type        = string
  description = "Execution environment"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in gibibytes"
  default     = 100
}

variable "storage_type" {
  type        = string
  description = "Storage Type e.g. SSD vs general purpose"
  default     = "gp2"
}

variable "instance_class" {
  type        = string
  description = "The ec2 instance class"
  default     = "db.t3.micro"
}

variable "db_subnet_group_name" {
  type        = string
  description = "The name of the subnet group that the DB spans across"
}

variable "backup_time_range_in_UTC" {
  type        = string
  description = "Backup window"
  default     = "08:00-11:00"
}

variable "retention_period_in_days" {
  type        = number
  description = "The backup image retention period"
  default     = 7
}

variable "apply_immediately" {
  type        = bool
  description = "Should the database apply changes immediately or during the maintenance window"
  default     = true
}

variable "deletion_protection" {
  type        = string
  description = "Will prevent the db from being deleted while true"
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "The id of the vpc where the database will reside"
}

variable "parameter_group_family" {
  type        = string
  description = "Name of the family for parameter group. Defaults to postgres12"
  default     = "postgres13"
}

variable "shared_preload_libraries" {
  type    = list(string)
  default = ["pg_stat_statements","pgaudit"]
}
