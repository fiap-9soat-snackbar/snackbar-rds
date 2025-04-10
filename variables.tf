variable "remote_state_bucket" {
  description = "S3 bucket for storing Terraform remote state"
  type        = string
}

variable "remote_state_key" {
  description = "Key for Terraform remote state in S3 bucket"
  type        = string
}

variable "remote_state_region" {
  description = "Region of S3 bucket for Terraform remote state"
  type        = string
}

# RDS Variables
variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "snackbar"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the database (should be provided via environment variables)"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "Version of MariaDB to use"
  type        = string
  default     = "10.6.14"
}

variable "db_backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip the final snapshot when destroying the database"
  type        = bool
  default     = true
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "db_publicly_accessible" {
  description = "Whether the database should be publicly accessible"
  type        = bool
  default     = false
}
