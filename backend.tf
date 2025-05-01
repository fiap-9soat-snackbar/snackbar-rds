provider "aws" {
  region = data.terraform_remote_state.global.outputs.aws_region

    default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = data.terraform_remote_state.global.outputs.project_name
    }
  }
}

terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region = "us-east-1"
    key    = "database/rds/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }

}

data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "global/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "network/vpc/terraform.tfstate"
  }
}