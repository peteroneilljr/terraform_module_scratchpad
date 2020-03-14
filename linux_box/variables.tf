  variable "server_name" {}
  variable "instance_type" {} 
  variable "monitoring" {}    
  variable "subnet_id" {}
  variable "vpc_id" {}
  variable "associate_public_ip_address" {}
  variable "key_name" {}
  # variable "ami" {}
  variable "tags" {}
  variable "private_key_path" {}
  #   user_data                   = data.template_file.sdm_auto_reg_server_ubuntu.rendered
# locals {
#   ubuntu_filters = {
#     "xenial" = "Windows_Server-2016-English*",
#     "trusty" = "Windows_Server-2019-English*"
#   }
#   windows_search = [for i, z in local.ubuntu_filters: z if i == var.windows_year][0]
# }
