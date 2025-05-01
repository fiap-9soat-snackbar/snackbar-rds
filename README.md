# Snackbar RDS MariaDB Infrastructure

This Terraform configuration provisions an AWS RDS MariaDB infrastructure for the Snackbar application, including the database instance, networking components, and monitoring.

## 🚀 Features

- **MariaDB RDS Instance**: Primary database for the Snackbar application
- **Security Groups**: Controlled access to the database instance
- **Parameter Group**: Optimized database settings for the application
- **CloudWatch Integration**: Monitoring and alerts for database operations
- **Terraform Provisioning**: Infrastructure-as-Code (IaC) for repeatable deployments

## 📐 Architecture

The RDS infrastructure follows this design:

1. **Database Layer**
   - RDS MariaDB instance in private subnets
   - Security group restricting access to the database
   - Parameter group with optimized settings

2. **Monitoring Layer**
   - CloudWatch alarms for CPU utilization
   - CloudWatch alarms for storage space
   - CloudWatch alarms for database connections

## 🛠️ Project Structure

```
.
├── main.tf                 # Main RDS instance configuration
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output value definitions
├── backend.tf              # Backend and Provider configuration
```

## 🛠️ Terraform Resources

| Resource Type | Purpose |
|---------------|---------|
| `aws_security_group` | Controls access to the RDS instance |
| `aws_db_subnet_group` | Groups subnets for RDS deployment |
| `aws_db_parameter_group` | Configures database parameters |
| `aws_db_instance` | Creates the MariaDB RDS instance |
| `aws_cloudwatch_metric_alarm` | Sets up monitoring and alerts |

## 🚀 Deployment

### Prerequisites
1. **AWS CLI Configured** with valid credentials
2. **Terraform v1.0+** installed

### Configuration Variables
- `db_instance_class`: Instance type for the database (default: db.t3.micro)
- `db_allocated_storage`: Storage size in GB (default: 20)
- `db_engine_version`: MariaDB version (default: 10.6.14)
- `db_multi_az`: High availability configuration (default: false)
- `db_backup_retention_period`: Days to retain backups (default: 7)
- `db_password`: Password for the database admin user (required in terraform.tfvars)

## 🛠️ How to Run Terraform

### Initialize Terraform with S3 Backend
Use the provided helper script to initialize Terraform with the S3 backend configuration:
```
./init.sh
```

### Plan Infrastructure
Preview changes before applying them (dry-run):
```
terraform plan -var-file=terraform.tfvars
```

### Apply Configuration
Create or update AWS resources:
```
terraform apply -var-file=terraform.tfvars -auto-approve
```

### Destroy Resources
Remove all created resources:
```
terraform destroy -var-file=terraform.tfvars -auto-approve
```

## 📊 Database Connection Information

After successful deployment, the following outputs are available:

- **Endpoint**: `snackbar-db.*.us-east-1.rds.amazonaws.com:3306`
- **Database Name**: `snackbar-db`
- **Username**: `admin`
- **Password**: As specified in terraform.tfvars (securely stored in Parameter Store)

## 🔍 Testing Database Connectivity

To test connectivity to the database, follow these steps:

### Option 1: Launch an EC2 Instance in the Same VPC

1. **Launch an EC2 instance**:
   - Go to AWS Console > EC2 > Instances > Launch Instance
   - Choose Amazon Linux 2023
   - Select t2.micro instance type
   - Configure the instance to use the same VPC as the database
   - Select one of the public subnets
   - Configure security group to allow SSH access (port 22)
   - Launch the instance with your key pair

2. **Connect to the EC2 instance**:
   - Use SSH or Session Manager to connect to the instance
   - Install the MySQL client:
     ```bash
     sudo yum update -y
     sudo yum install -y mariadb105
     ```

3. **Connect to the database**:
   ```bash
   mysql -h <database-endpoint> -P 3306 -u admin -p
   ```
   - When prompted, enter the database password from terraform.tfvars

4. **Run test queries**:
   ```sql
   SHOW DATABASES;
   SELECT VERSION(), NOW();
   CREATE DATABASE test;
   USE test;
   CREATE TABLE test_table (id INT AUTO_INCREMENT PRIMARY KEY, message VARCHAR(255), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
   INSERT INTO test_table (message) VALUES ('Test message');
   SELECT * FROM test_table;
   ```

### Option 2: Use AWS Cloud9

1. **Create a Cloud9 environment**:
   - Go to AWS Console > Cloud9 > Create environment
   - Configure the environment to use the same VPC as the database
   - Select one of the public subnets

2. **Install the MySQL client**:
   ```bash
   sudo yum install -y mariadb105
   ```

3. **Connect to the database** using the same commands as in Option 1.

### Option 3: Use AWS RDS Query Editor

1. Go to AWS Console > RDS > Databases
2. Select the snackbar-db instance
3. Click on "Query Editor" in the top menu
4. Enter the database credentials and connect
5. Run SQL queries in the editor

Note: The database is in a private subnet with security group restrictions, so any client connecting to it must be within the same VPC or have proper network connectivity configured.
