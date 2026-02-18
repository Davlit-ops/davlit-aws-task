output "app_public_ip" {
  description = "Use this IP in your browser to access the eSchool app"
  value       = aws_instance.app.public_ip
}

output "db_private_ip" {
  description = "Internal DB address for application.properties (Security first!)"
  value       = aws_instance.db.private_ip
}
