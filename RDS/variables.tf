variable "vpc_id" {}
variable "subnet_ids" {}
variable "db_engine" {}
variable "db_engine_version" {
  default = ""
}
variable "default_tags" {
  default = {
    ManagedBy = "Terraform"
  }
}
variable "admin_username" {
  default = "aurora"
}
variable "admin_password" {
}

variable "db_count" {
  default = 1
}
variable "publicly_accessible" {
  default = true
}
variable "db_engine_mode" {
  default = "provisioned"
}
variable "db_auto_upgrade" {
  default = false
}
variable "db_identifier" {
  default = ""
}
variable "db_instance_class" {}
variable "db_skip_final" {
  default = true
}
variable "db_port" {}
variable "db_backtrack" {
  default = 0
}
variable "sdm_admin_token" {
  default = ""
}

resource "random_password" "aurora" {
  length           = 16
  special          = true
  override_special = "_%@"
}


locals {
  #   sdm_add_aurora_postgres    = <<SDMCLI
  # SDM_ADMIN_TOKEN="${var.sdm_admin_token}"; \
  # /usr/local/bin/sdm admin datasources delete ${var.db_identifier}; \
  # /usr/local/bin/sdm admin datasources add aurora-postgres \
  # --database ${var.db_identifier} \
  # --hostname ${aws_rds_cluster.aurora.endpoint} \
  # --password ${local.password} \
  # --port ${var.db_port} \
  # --username ${var.admin_username} \
  # --tags 'creator=peter,managed_by=terraform' \
  # ${var.db_identifier} && \
  # echo "added 1 datasource ${var.db_identifier}" && \
  # /usr/local/bin/sdm admin roles grant ${var.db_identifier} AWS
  # SDMCLI
  #   sdm_remove_aurora_postgres = <<SDMCLI
  # SDM_ADMIN_TOKEN="${var.sdm_admin_token}"; \
  # /usr/local/bin/sdm admin datasources delete ${var.db_identifier}
  # SDMCLI
  password = var.admin_password != "" ? var.admin_password : random_password.aurora.result
}

