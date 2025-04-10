#--------------------------------------------------------------
# RDS MariaDB Resources
#--------------------------------------------------------------

# RDS MariaDB Instance
resource "aws_db_instance" "mariadb" {
  identifier             = "${local.project_name}-db"
  engine                 = "mariadb"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  max_allocated_storage  = var.db_allocated_storage * 2
  storage_type           = "gp2"
  storage_encrypted      = true
  
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  port                   = 3306
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.mariadb_params.name
  
  backup_retention_period      = var.db_backup_retention_period
  backup_window                = "03:00-06:00"
  maintenance_window           = "Mon:00:00-Mon:03:00"
  auto_minor_version_upgrade   = true
  deletion_protection          = true
  skip_final_snapshot          = var.db_skip_final_snapshot
  final_snapshot_identifier    = "${local.project_name}-final-snapshot"
  
  multi_az                     = var.db_multi_az
  publicly_accessible          = var.db_publicly_accessible
  
  tags = {
    Name        = "${local.project_name}-db"
    Environment = local.environment
    Project     = local.project_name
  }
}

# Parameter Group for MariaDB
resource "aws_db_parameter_group" "mariadb_params" {
  name        = "${local.project_name}-mariadb-params"
  family      = "mariadb10.6"
  description = "Parameter group for ${local.project_name} MariaDB instance"
  
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  
  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }
  
  tags = {
    Name        = "${local.project_name}-mariadb-params"
    Environment = local.environment
    Project     = local.project_name
  }
}
