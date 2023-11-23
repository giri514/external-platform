locals {
  postgres-db = jsondecode(data.aws_secretsmanager_secret_version.postgres-db.secret_string)
}


resource "aws_rds_cluster" "db_postgres" {
  engine                                = "aurora-postgresql"
  engine_version                        = "13.10"
  engine_mode                           = "provisioned"
  database_name                         = local.postgres-db.dbname
  port                                  = 5432
  cluster_identifier                    = "${local.postgres-db.dbInstanceIdentifier}-cluster"
  master_username                       = local.postgres-db.username
  master_password                       = local.postgres-db.password
  db_subnet_group_name                  = var.db_subnet_group_name
  db_instance_parameter_group_name      = aws_db_parameter_group.parameter_group_reece_db.name
  vpc_security_group_ids                = [aws_security_group.rds_security_group.id]
  apply_immediately                     = var.apply_immediately
  deletion_protection                   = var.deletion_protection
  enabled_cloudwatch_logs_exports       = ["postgresql"]
  storage_encrypted                     = false
  backup_retention_period               = var.retention_period_in_days
  
  serverlessv2_scaling_configuration {
    max_capacity = 64
    min_capacity = 1
  }

  tags = {
    Purpose            = "ReeceDBPostGres"
    Supported_By       = "Cloud Infrastructure Team"
    Managed_By         = "Digital Solutions Team"
    RDS_Backup_Enabled = "true"
    "Backup_Enabled"   = "true"
  }
}

resource "aws_db_parameter_group" "parameter_group" {
  name   = "rds-pg-grp"
  family = var.parameter_group_family

  parameter {
    name = "idle_in_transaction_session_timeout"
    value = "60000"
  }

  parameter {
    name = "log_min_duration_statement"
    value = 500
  }

  parameter {
    name = "log_statement"
    value = "all"

   }

  parameter {
    name = "pg_stat_statements.max"
    value = 10000
    apply_method = "pending-reboot"
  }

  parameter {
    name = "pg_stat_statements.track"
    value = "all"
  }

  parameter {
    name = "shared_preload_libraries"
    value = "${join(",", "${var.shared_preload_libraries}")}"
    apply_method = "pending-reboot"
  }

  parameter {
    apply_method = "pending-reboot"
    name         = "pgaudit.role"
    value        = "rds_pgaudit"
  }
}

resource "aws_db_parameter_group" "parameter_group_reece_db" {
  name   = "reece-db-pg-grp"
  family = var.parameter_group_family

  parameter {
    name = "idle_in_transaction_session_timeout"
    value = "180000"
  }

  parameter {
    name = "log_min_duration_statement"
    value = 0
  }

  parameter {
    name = "log_statement"
    value = "all"

   }

  parameter {
    name = "log_connections"
    value = "1"

   }

  parameter {
    name = "log_disconnections"
    value = "1"

   }

  parameter {
    name = "log_lock_waits"
    value = "1"

   }

  parameter {
    name = "log_temp_files"
    value = "1"

   }

  parameter {
    name = "log_autovacuum_min_duration"
    value = "0"

   }

  parameter {
    name = "log_error_verbosity"
    value = "default"

   }

  parameter {
    name = "lc_messages"
    value = "C"

   }

  parameter {
    name = "rds.force_autovacuum_logging_level"
    value = "log"

   }

  parameter {
    name = "pg_stat_statements.max"
    value = 10000
    apply_method = "pending-reboot"
  }

  parameter {
    name = "pg_stat_statements.track"
    value = "all"
  }

  parameter {
    name = "shared_preload_libraries"
    value = "${join(",", "${var.shared_preload_libraries}")}"
    apply_method = "pending-reboot"
  }

  parameter {
    apply_method = "pending-reboot"
    name         = "pgaudit.role"
    value        = "rds_pgaudit"
  }
}

resource "aws_db_parameter_group" "parameter_group_wms" {
  name   = "wms-pg-grp"
  family = var.parameter_group_family

  parameter {
    name = "idle_in_transaction_session_timeout"
    value = "60000"
  }

  parameter {
    name = "log_min_duration_statement"
    value = 0
  }

  parameter {
    name = "log_statement"
    value = "all"

   }

  parameter {
    name = "log_connections"
    value = "1"

   }

  parameter {
    name = "log_disconnections"
    value = "1"

   }

  parameter {
    name = "log_lock_waits"
    value = "1"

   }

  parameter {
    name = "log_temp_files"
    value = "1"

   }

  parameter {
    name = "log_autovacuum_min_duration"
    value = "0"

   }

  parameter {
    name = "log_error_verbosity"
    value = "default"

   }

  parameter {
    name = "lc_messages"
    value = "C"

   }

  parameter {
    name = "rds.force_autovacuum_logging_level"
    value = "log"

   }

  parameter {
    name = "pg_stat_statements.max"
    value = 10000
    apply_method = "pending-reboot"
  }

  parameter {
    name = "pg_stat_statements.track"
    value = "all"
  }

  parameter {
    name = "shared_preload_libraries"
    value = "${join(",", "${var.shared_preload_libraries}")}"
    apply_method = "pending-reboot"
  }

  parameter {
    apply_method = "pending-reboot"
    name         = "pgaudit.role"
    value        = "rds_pgaudit"
  }
}

resource "aws_db_parameter_group" "parameter_group_special_pricing" {
  name   = "special-pricing-pg-grp"
  family = var.parameter_group_family

  parameter {
    name = "idle_in_transaction_session_timeout"
    value = "60000"
  }

  parameter {
    name = "log_min_duration_statement"
    value = 0
  }

  parameter {
    name = "log_statement"
    value = "all"

   }

  parameter {
    name = "log_connections"
    value = "1"

   }

  parameter {
    name = "log_disconnections"
    value = "1"

   }

  parameter {
    name = "log_lock_waits"
    value = "1"

   }

  parameter {
    name = "log_temp_files"
    value = "1"

   }

  parameter {
    name = "log_autovacuum_min_duration"
    value = "0"

   }

  parameter {
    name = "log_error_verbosity"
    value = "default"

   }

  parameter {
    name = "lc_messages"
    value = "C"

   }

  parameter {
    name = "rds.force_autovacuum_logging_level"
    value = "log"

   }

  parameter {
    name = "pg_stat_statements.max"
    value = 10000
    apply_method = "pending-reboot"
  }

  parameter {
    name = "pg_stat_statements.track"
    value = "all"
  }

  parameter {
    name = "shared_preload_libraries"
    value = "${join(",", "${var.shared_preload_libraries}")}"
    apply_method = "pending-reboot"
  }

  parameter {
    apply_method = "pending-reboot"
    name         = "pgaudit.role"
    value        = "rds_pgaudit"
  }
}

