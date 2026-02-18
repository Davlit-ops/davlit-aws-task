variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

# Database Variables

variable "db_username" {
  description = "Username for the MySQL database"
  type        = string
}

variable "db_password" {
  description = "Password for the MySQL database"
  type        = string
  sensitive   = true
}

# SSH & Key Variables

variable "key_name" {
  description = "Name of the SSH key pair in AWS"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public SSH key file on your local machine"
  type        = string
}
