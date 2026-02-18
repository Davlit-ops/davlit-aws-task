variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "aws_access_key" {
  description = "The access key for our new softserve-admin user"
  type        = string
}

variable "aws_secret_key" {
  description = "The secret key for our new softserve-admin user"
  type        = string
  sensitive   = true # This hides the secret in terminal outputs
}

variable "key_name" {
  description = "Name of the SSH key pair to use for instances"
  type        = string
  default     = "vlad-key"
}

variable "db_username" {
  description = "Username for the MySQL database"
  type        = string
  default     = "vlad_db_admin"
}

variable "db_password" {
  description = "Password for the MySQL database"
  type        = string
  sensitive   = true
}
