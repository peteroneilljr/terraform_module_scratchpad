# This module creates linux boxes

## Sample

~~~
module "ubuntu" {
  source = "./modules/ubuntu"
  server_name                 = "ubuntu"
  instance_type               = "t3.small"
  ubuntu_release              = "xenial"
  monitoring                  = false
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_id                      = module.vpc.vpc_id
  key_name                    = aws_key_pair.sdm_key.key_name
  private_key_path            = var.private_key_path

  tags = var.default_tags
}
output "ubuntu_login" {
  value = module.ubuntu.ssh_login
}
~~~