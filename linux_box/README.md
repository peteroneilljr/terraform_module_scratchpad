# This module creates linux boxes

## Sample

~~~
module "ubuntu" {
  source = "./modules/linux_box"
  server_name    = "ubuntu"
  instance_type               = "t3.small"
  monitoring                  = true
  subnet_id                   = aws_subnet.peter_public_subnet[0].id
  vpc_id      = aws_vpc.peter_vpc.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.sdm_key.key_name
  # ami                         = data.aws_ami.ubuntu-16_04.image_id
  private_key_path       = var.private_key_path
  #   user_data                   = data.template_file.sdm_auto_reg_server_ubuntu.rendered


  tags = var.default_tags
}
output "ubuntu_login" {
  value = module.ubuntu.ssh_login
}
~~~