variable "gateway_listen_port" {
  default = 5000
}
variable "sdm_gateway_name" {

}
variable "ssh_access" {
  default = false
}
variable "deploy_vpc_id" {

}

variable "deploy_subnet_id" {

}

variable "ssh_key" {

}
variable "ssh_source" {
  default = "0.0.0.0/0"
}


data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}
variable "tags" {

}

