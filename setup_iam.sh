#!/bin/bash

# Exit on any error
set -e

# Basic config
USER_NAME="softserve-admin"
KEYS_DEST="vlad_access_keys.json"
ADMIN_POLICY="arn:aws:iam::aws:policy/AdministratorAccess"

# Quick auth check
if [ "$#" -eq 2 ]; then
    echo "Found credentials in arguments, setting up environment..."
    export AWS_ACCESS_KEY_ID=$1
    export AWS_SECRET_ACCESS_KEY=$2
    export AWS_DEFAULT_REGION="us-east-2"
fi

# Checking if we actually have access to AWS
if ! aws sts get-caller-identity --query "Arn" --output text > /dev/null 2>&1; then
    echo "Whoops! No AWS identity found. Run 'aws configure' first or pass keys as arguments."
    exit 1
fi

# Creating the admin user
if aws iam get-user --user-name "$USER_NAME" > /dev/null 2>&1; then
    echo "User '$USER_NAME' is already here, skipping creation."
else
    echo "Creating new IAM user: $USER_NAME..."
    aws iam create-user --user-name "$USER_NAME"
fi

# Giving the user admin powers
echo "Attaching AdministratorAccess"
aws iam attach-user-policy --user-name "$USER_NAME" --policy-arn "$ADMIN_POLICY"

# Generating keys and dumping them to a file
# Heads up: this creates a new key pair every time you run it!
echo "Generating fresh access keys..."
aws iam create-access-key --user-name "$USER_NAME" --output json > "$KEYS_DEST"

echo "All set! Check '$KEYS_DEST' for your new secrets."
echo "Don't forget to put them into your Terraform vars."
