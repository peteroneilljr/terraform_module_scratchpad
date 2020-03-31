variable "server_name" {}
variable "instance_type" {} 
variable "monitoring" {}    
variable "subnet_id" {}
variable "vpc_id" {}
variable "key_name" {}
variable "tags" {}
variable "private_key_path" {}
variable "ubuntu_release" {}
locals {
  username = "ubuntu"
  ubuntu_filters = {
    "trusty" = "ubuntu/images/hvm-ssd/ubuntu-trusty*",
    "xenial" = "ubuntu/images/hvm-ssd/ubuntu-xenial*",
    "bionic" = "ubuntu/images/hvm-ssd/ubuntu-bionic*"
  }
  ubuntu_search = [for version, filter in local.ubuntu_filters: filter if version == var.ubuntu_release][0]
  ubuntu_account_number = "099720109477"
}
#################
# Grab latest ubuntu AMI ID
#################
data "aws_ami" "ubuntu" {
  # aws ec2 describe-images --filters 'Name=state,Values=available' 'Name=architecture,Values=x86_64' 'Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic*' --region 'us-west-2' --query 'reverse(sort_by(Images, &CreationDate))[:1]' --output json
  most_recent = true
  owners      = [local.ubuntu_account_number]

  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = [local.ubuntu_search]
  }

}

