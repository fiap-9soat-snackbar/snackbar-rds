terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
  
  backend "s3" {
    # These values should be provided during terraform init or via environment variables
  }
}

provider "aws" {
  region = local.region
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = local.environment
      Project     = local.project_name
    }
  }
}
