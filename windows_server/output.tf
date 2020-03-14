output "public_dns" {
  value = aws_instance.windows_server.public_dns
}
output "password_data" {
  value     = aws_instance.windows_server.password_data
}
# output "password_data" {
#   value     = "${rsadecrypt(aws_instance.windows_server.password_data, file("/home/ec2-user/.ssh/peter-pair.pem"))}"
# }