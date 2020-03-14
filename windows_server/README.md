# Generate Windows Server AMI


## Sample deploy
```

module "windows_server" {
  source = "./modules/windows_server"
  server_name  = "windows_2008"
  
  monitoring                  = true
  get_password_data           = true
  associate_public_ip_address = true

  vpc_id    = aws_vpc.peter_vpc.id
  subnet_id = aws_subnet.peter_public_subnet[0].id
  key_name  = aws_key_pair.sdm_key.key_name
  windows_year = "2016"

  default_tags = var.default_tags
}

output "windows_server_password_data" {
  value     = rsadecrypt(module.windows_server.password_data, file(var.private_key_path))
  sensitive = true
}
output "windows_server_public_dns" {
  value = module.windows_server.public_dns
}
```