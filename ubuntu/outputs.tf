
output "ssh_login" {
  value = "ssh -i '${var.private_key_path}' ubuntu@${aws_instance.ubuntu.public_dns}"
}