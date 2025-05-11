#--------------------------------------------------------------
# RDS MariaDB Resources
#--------------------------------------------------------------

# RDS MariaDB Instance
resource "aws_db_instance" "mariadb" {
  identifier             = "${data.terraform_remote_state.global.outputs.project_name}-db"
  engine                 = "mariadb"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  max_allocated_storage  = var.db_allocated_storage * 2
  storage_type           = "gp3"
  storage_encrypted      = true
  
  db_name                = data.terraform_remote_state.global.outputs.project_name
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
  deletion_protection          = false
  skip_final_snapshot          = var.db_skip_final_snapshot
  final_snapshot_identifier    = "${data.terraform_remote_state.global.outputs.project_name}-final-snapshot"
  
  multi_az                     = var.db_multi_az
  publicly_accessible          = var.db_publicly_accessible
  
  tags = {
    Name        = "${data.terraform_remote_state.global.outputs.project_name}-db"
    Project     = data.terraform_remote_state.global.outputs.project_name
  }
}

# Parameter Group for MariaDB
resource "aws_db_parameter_group" "mariadb_params" {
  name        = "${data.terraform_remote_state.global.outputs.project_name}-mariadb-params"
  family      = "mariadb10.6"
  description = "Parameter group for ${data.terraform_remote_state.global.outputs.project_name} MariaDB instance"
  
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  
  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }
  
  tags = {
    Name        = "${data.terraform_remote_state.global.outputs.project_name}-mariadb-params"
    Project     = data.terraform_remote_state.global.outputs.project_name
  }
}

#--------------------------------------------------------------
# Security Resources
#--------------------------------------------------------------

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "${data.terraform_remote_state.global.outputs.project_name}-rds-sg"
  description = "Security group for ${data.terraform_remote_state.global.outputs.project_name} RDS instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.30.20.0/24", "10.30.21.0/24", "10.30.22.0/24"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${data.terraform_remote_state.global.outputs.project_name}-rds-sg"
    Project     = data.terraform_remote_state.global.outputs.project_name
  }
}

# Subnet Group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${data.terraform_remote_state.global.outputs.project_name}-subnet-group"
  description = "Subnet group for ${data.terraform_remote_state.global.outputs.project_name} RDS instance"
  #subnet_ids  = aws_subnet.private[*].id
  subnet_ids  = data.terraform_remote_state.vpc.outputs.database_subnets
  
  tags = {
    Name        = "${data.terraform_remote_state.global.outputs.project_name}-subnet-group"
    Project     = data.terraform_remote_state.global.outputs.project_name
  }
}

#--------------------------------------------------------------
# CloudWatch Resources
#--------------------------------------------------------------

# CloudWatch Alarm for CPU Utilization
resource "aws_cloudwatch_metric_alarm" "db_cpu_utilization_alarm" {
  alarm_name          = "${data.terraform_remote_state.global.outputs.project_name}-db-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors RDS CPU utilization"
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.mariadb.id
  }
  
  tags = {
    Name        = "${data.terraform_remote_state.global.outputs.project_name}-db-cpu-alarm"
    Project     = data.terraform_remote_state.global.outputs.project_name
  }
}

# CloudWatch Alarm for Free Storage Space
resource "aws_cloudwatch_metric_alarm" "db_free_storage_space_alarm" {
  alarm_name          = "${data.terraform_remote_state.global.outputs.project_name}-db-free-storage-space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120  # 5GB in bytes
  alarm_description   = "This metric monitors RDS free storage space"
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.mariadb.id
  }
  
  tags = {
    Name        = "${data.terraform_remote_state.global.outputs.project_name}-db-storage-alarm"
    Project     = data.terraform_remote_state.global.outputs.project_name
  }
}

# CloudWatch Alarm for Database Connections
resource "aws_cloudwatch_metric_alarm" "db_connections_alarm" {
  alarm_name          = "${data.terraform_remote_state.global.outputs.project_name}-db-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 100  # Adjust based on your expected connection load
  alarm_description   = "This metric monitors the number of database connections"
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.mariadb.id
  }
  
  tags = {
    Name        = "${data.terraform_remote_state.global.outputs.project_name}-db-connections-alarm"
    Project     = data.terraform_remote_state.global.outputs.project_name
  }
}
