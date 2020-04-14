variable "cluster_name" {}
variable "vpc_id" {}
variable "vpc_igw" {}
variable "vpc_cidr" {}
variable "eks_cidr_block" {}
variable "tags" {
  default = null
}
