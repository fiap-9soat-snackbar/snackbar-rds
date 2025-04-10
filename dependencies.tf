#--------------------------------------------------------------
# Network Resources
#--------------------------------------------------------------

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = "${local.project_name}-vpc"
    Environment = local.environment
    Project     = local.project_name
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = "${local.region}${count.index == 0 ? "a" : "b"}"
  map_public_ip_on_launch = true
  
  tags = {
    Name        = "${local.project_name}-public-subnet-${count.index + 1}"
    Environment = local.environment
    Project     = local.project_name
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 10}.0/24"
  availability_zone       = "${local.region}${count.index == 0 ? "a" : "b"}"
  
  tags = {
    Name        = "${local.project_name}-private-subnet-${count.index + 1}"
    Environment = local.environment
    Project     = local.project_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name        = "${local.project_name}-igw"
    Environment = local.environment
    Project     = local.project_name
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name        = "${local.project_name}-public-rt"
    Environment = local.environment
    Project     = local.project_name
  }
}

# Route Table Association for Public Subnets
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name        = "${local.project_name}-private-rt"
    Environment = local.environment
    Project     = local.project_name
  }
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

#--------------------------------------------------------------
# Security Resources
#--------------------------------------------------------------

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "${local.project_name}-rds-sg"
  description = "Security group for ${local.project_name} RDS instance"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${local.project_name}-rds-sg"
    Environment = local.environment
    Project     = local.project_name
  }
}

# Subnet Group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${local.project_name}-subnet-group"
  description = "Subnet group for ${local.project_name} RDS instance"
  subnet_ids  = aws_subnet.private[*].id
  
  tags = {
    Name        = "${local.project_name}-subnet-group"
    Environment = local.environment
    Project     = local.project_name
  }
}

#--------------------------------------------------------------
# CloudWatch Resources
#--------------------------------------------------------------

# CloudWatch Alarm for CPU Utilization
resource "aws_cloudwatch_metric_alarm" "db_cpu_utilization_alarm" {
  alarm_name          = "${local.project_name}-db-cpu-utilization"
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
    Name        = "${local.project_name}-db-cpu-alarm"
    Environment = local.environment
    Project     = local.project_name
  }
}

# CloudWatch Alarm for Free Storage Space
resource "aws_cloudwatch_metric_alarm" "db_free_storage_space_alarm" {
  alarm_name          = "${local.project_name}-db-free-storage-space"
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
    Name        = "${local.project_name}-db-storage-alarm"
    Environment = local.environment
    Project     = local.project_name
  }
}

# CloudWatch Alarm for Database Connections
resource "aws_cloudwatch_metric_alarm" "db_connections_alarm" {
  alarm_name          = "${local.project_name}-db-connections"
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
    Name        = "${local.project_name}-db-connections-alarm"
    Environment = local.environment
    Project     = local.project_name
  }
}
