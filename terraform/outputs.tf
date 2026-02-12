output "app_public_ip" {
  description = "Public IP of the Application Server"
  value       = aws_instance.app.public_ip
}

output "db_public_ip" {
  description = "Public IP of the Database Server"
  value       = aws_instance.db.public_ip
}

output "db_private_ip" {
  description = "Private IP of the DB for application.properties"
  value       = aws_instance.db.private_ip
}
