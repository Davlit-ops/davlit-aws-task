variable "aws_region" {
  default = "us-east-2"
}

variable "aws_access_key" {
  description = "AWS Access Key"
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  sensitive   = true
}

variable "key_name" {
  description = "Name of the SSH key pair to use for instances"
  type        = string
  default     = "vlad-key"
}
