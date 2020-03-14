output "endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}

output "password" {
  value     = local.password
  sensitive = true
}
