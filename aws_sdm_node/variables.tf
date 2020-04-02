variable "sdm_node_name" {
  description = "This name is applied to resources where applicable, e.g. titles and tags."
  type        = string
  default     = "strongDM"
}
variable "deploy_vpc_id" {
  description = "VPC IP is used to assign security groups in the correct network"
  type        = string
}
variable "gateway_listen_port" {
  description = "Port for strongDM gateways to listen for incoming connections"
  type        = number
  default     = 5000
}
variable "deploy_gw_subnet_ids" {
  description = "strongDM gateways will be deployed into subnets provided"
  type        = list(string)
  default     = []
}
variable "deploy_relay_subnet_ids" {
  description = "strongDM relays will be deployed into subnets provided"
  type        = list(string)
  default     = []
}
variable "ssh_access" {
  description = "Enable or diseable SSH access to gateways and relays"
  type        = bool
  default     = false
}
variable "ssh_key" {
  description = "Public key to add to instances"
  type        = string
  default     = null
}
variable "ssh_source" {
  description = "Restric SSH access, default is allow from anywahere"
  type        = string
  default     = "0.0.0.0/0"
}
variable "tags" {
  description = "Tags to be applied to reasources created by this module"
  type        = map(string)
  default     = {}
}
variable "dev_mode" {
  description = "Enable to deploy smaller sized instances for testing"
  type        = bool
  default     = false
}
variable "detailed_monitoiring" {
  description = "Enable detailed monitoring all instances created"
  type = bool
  default = false
}
variable "disable_dns" {
  description = "Use IP address of EIP instead of DNS hostname"
  type = bool
  default = false
}
variable "customer_key" {
  description = "Specify a customer key to use for parameter store encryption."
  type = string
  default = null
}
variable "enable_cpu_alarm" {
  description = "CloudWatch alarm: 75% cpu utilization for 10 minutes."
  trype = bool
  default = false
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