#!/bin/bash

# Error handling
set -e

# Config
USER_NAME="softserve-admin"

# Create an IAM user
echo "Creating IAM user: $USER_NAME"
aws iam create-user --user-name "$USER_NAME"

# Assign administrator permissions
echo "Attaching AdministratorAccess policy"
aws iam attach-user-policy \
    --user-name "$USER_NAME" \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Create access keys
echo "Creating access keys"
echo "Save the AccessKeyId and SecretAccessKey"
aws iam create-access-key --user-name "$USER_NAME"
