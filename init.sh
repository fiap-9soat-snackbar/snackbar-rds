#!/bin/bash

# Extract values from terraform.tfvars
BUCKET=$(grep remote_state_bucket terraform.tfvars | cut -d '=' -f2 | tr -d ' "')
KEY=$(grep remote_state_key terraform.tfvars | cut -d '=' -f2 | tr -d ' "')
REGION=$(grep remote_state_region terraform.tfvars | cut -d '=' -f2 | tr -d ' "')

echo "Initializing Terraform with backend configuration:"
echo "  Bucket: $BUCKET"
echo "  Key: $KEY"
echo "  Region: $REGION"
echo ""

# Initialize Terraform with backend configuration
terraform init \
  -backend-config="bucket=$BUCKET" \
  -backend-config="key=$KEY" \
  -backend-config="region=$REGION"

# Check if db_password is set in terraform.tfvars
if ! grep -q "db_password" terraform.tfvars; then
  echo "ERROR: db_password is not set in terraform.tfvars"
  echo "Please add a db_password variable to terraform.tfvars"
  exit 1
fi

echo "Database password found in terraform.tfvars"
