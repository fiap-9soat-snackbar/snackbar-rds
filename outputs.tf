output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.mariadb.endpoint
}

output "rds_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.mariadb.port
}

output "rds_name" {
  description = "The database name"
  value       = aws_db_instance.mariadb.db_name
}

output "rds_username" {
  description = "The master username for the database"
  value       = aws_db_instance.mariadb.username
  sensitive   = true
}
output "security_group_id" {
  description = "The ID of the security group for the RDS instance"
  value       = aws_security_group.rds_sg.id
}