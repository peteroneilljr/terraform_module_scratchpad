
variable "sdm_role_ids" {}

variable "vpc_id" {}
variable "subnet_ids" {}
variable "db_engine" {}
variable "db_engine_version" {
  default = null
}
variable "default_tags" {
  default = {
    ManagedBy = "Terraform"
  }
}
variable "admin_username" {
  default = "strongdm"
}
variable "admin_password" {
  default = ""
}

variable "db_count" {
  default = 1
}
variable "publicly_accessible" {
  default = true
}
variable "storage_size" {
  default = 20
}
variable "db_engine_mode" {
  default = "provisioned"
}
variable "db_auto_upgrade" {
  default = false
}
variable "db_identifier" {
  default = null
}
variable "db_instance_class" {
  default = "db.m4.large"
}
variable "db_skip_final" {
  default = true
}
variable "db_port" {
  default = 1521
}
variable "db_backtrack" {
  default = 0
}
variable "create_sdm" {
  default = false
}
resource "random_password" "rds" {
  count = var.admin_password != "" ? 0:1
  length           = 16
  special          = true
  override_special = "_%@"
}

locals {
  password = var.admin_password != "" ? var.admin_password : random_password.rds[0].result
}

