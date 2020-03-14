output "endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "password" {
  value     = local.password
  sensitive = true
}
