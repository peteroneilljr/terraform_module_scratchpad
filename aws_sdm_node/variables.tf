variable "gateway_listen_port" {
  description = "Port for strongDM gateways to listen for incoming connections"
  type        = number
  default     = 5000
}

variable "sdm_node_name" {

}
variable "deploy_vpc_id" {

}

variable "deploy_gw_subnet_ids" {
  description = "List of subnets to deploy strongDM gateways"
  type        = list(string)
  default     = []

}
variable "deploy_relay_subnet_ids" {
  description = "List of subnets to deploy strongDM relays"
  type        = list(string)
  default     = []
}

variable "ssh_access" {
  description = "Enable or diseable SSH access to gateways and relays"
  type        = bool
  default     = false
}
variable "ssh_key" {

}
variable "ssh_source" {
  description = "Restric SSH access, default is allow from anywahere"
  type        = string
  default     = "0.0.0.0/0"
}
variable "tags" {
  description = "Default tags applied to all reasources created by module"
  type        = map(string)
  default     = {}
}
variable "dev_mode" {
  type        = bool
  default     = false
  description = "Enable to deploy smaller sized instances for testing"
}


#################
# Sources latest Amazon Linux 2 AMI ID
#################
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