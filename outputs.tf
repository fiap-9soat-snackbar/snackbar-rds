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

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "security_group_id" {
  description = "The ID of the security group for the RDS instance"
  value       = aws_security_group.rds_sg.id
}

output "db_connection_instructions" {
  description = "Instructions for connecting to the database"
  value = <<-EOT
    To connect to the database:

    1. Launch an EC2 instance in the same VPC (${aws_vpc.main.id})
       - Use one of the public subnets: ${join(", ", aws_subnet.public[*].id)}
       - Configure security group to allow SSH access (port 22)

    2. Install the MySQL client:
       sudo yum update -y
       sudo yum install -y mariadb105

    3. Connect to the database:
       mysql -h ${aws_db_instance.mariadb.address} -P ${aws_db_instance.mariadb.port} -u ${aws_db_instance.mariadb.username} -p

    4. When prompted, enter the database password from terraform.tfvars

    5. Run test queries:
       SHOW DATABASES;
       SELECT VERSION(), NOW();
       CREATE DATABASE test;
       USE test;
       CREATE TABLE test_table (id INT AUTO_INCREMENT PRIMARY KEY, message VARCHAR(255));
       INSERT INTO test_table (message) VALUES ('Test message');
       SELECT * FROM test_table;
  EOT
}
