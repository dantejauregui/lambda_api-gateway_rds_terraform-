#!/bin/bash

# === CONFIGURATION ===
REGION="eu-central-1"
BUCKET_NAME="my-terraform-state-lambda-api-rds"
DYNAMODB_TABLE_NAME="terraform-locks"

# === CREATE S3 BUCKET ===
echo "Creating S3 bucket: $BUCKET_NAME in region: $REGION..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

# === ENABLE VERSIONING ===
echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

echo "Backend setup complete!"
