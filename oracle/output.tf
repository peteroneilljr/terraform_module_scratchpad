output "endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "credentials" {
  value     = "${var.admin_username}:${local.password}"
  sensitive = true
}
