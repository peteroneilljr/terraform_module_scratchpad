###############################################################################
# RDS resources
###############################################################################
#  * RDS Cluster
#  * RDS Cluster Instances
#  * RDS Subnet Group
#  * Security Group

# resource "aws_rds_cluster" "aurora" {
#   cluster_identifier     = var.db_identifier
#   engine                 = var.db_engine
#   engine_mode            = var.db_engine_mode
#   engine_version         = var.db_engine_version
#   skip_final_snapshot    = var.db_skip_final
#   backtrack_window       = var.db_backtrack
#   db_subnet_group_name   = aws_db_subnet_group.aurora.name
#   port                   = var.db_port
#   vpc_security_group_ids = [aws_security_group.aurora.id]
#   database_name          = var.db_identifier
#   master_username        = var.admin_username
#   master_password        = local.password

#   dynamic "scaling_configuration" {
#     for_each = var.db_engine_mode == "serverless" ? [var.db_engine_mode] : []
#     content {
#       auto_pause               = true
#       max_capacity             = 16
#       min_capacity             = 2
#       seconds_until_auto_pause = 300
#       timeout_action           = "RollbackCapacityChange"
#     }
#   }
#   tags = var.default_tags
# }


# resource "aws_rds_cluster_instance" "aurora" {
#   count                      = var.db_engine_mode == "serverless" ? 0 : var.db_count
#   publicly_accessible        = var.publicly_accessible
#   engine                     = var.db_engine
#   engine_version             = var.db_engine_version
#   auto_minor_version_upgrade = var.db_auto_upgrade
#   identifier                 = "${var.db_identifier}${count.index}"
#   cluster_identifier         = aws_rds_cluster.aurora.id
#   instance_class             = var.db_instance_class
#   db_subnet_group_name       = aws_db_subnet_group.aurora.name
#   tags                       = var.default_tags
# }

#################
# Oracle DB
#################

resource "aws_db_instance" "rds" {
  allocated_storage   = 20
  engine              = var.db_engine
  publicly_accessible = var.publicly_accessible
  engine_version      = var.db_engine_version
  identifier          = var.db_identifier
  instance_class      = var.db_instance_class
  # name                 = var.db_identifier
  skip_final_snapshot         = var.db_skip_final
  allow_major_version_upgrade = var.db_auto_upgrade
  auto_minor_version_upgrade  = var.db_auto_upgrade
  username                    = var.admin_username
  password                    = var.admin_password
  db_subnet_group_name        = aws_db_subnet_group.rds.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  tags                        = var.default_tags

  lifecycle {
    ignore_changes = [engine_version]
  }
}

#################
# Networking
#################
resource "aws_db_subnet_group" "rds" {
  name       = var.db_identifier
  subnet_ids = var.subnet_ids
  tags       = var.default_tags
}

resource "aws_security_group" "rds" {
  name        = var.db_identifier
  description = var.db_identifier
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.default_tags
}

#################
# strongDM register
#################
# resource "null_resource" "aurora" {
#   count = var.sdm_admin_token != "" ? 1 : 0
#   triggers = {
#     cluster_instance_ids = aws_rds_cluster.aurora.id
#   }
#   provisioner "local-exec" {
#     command = local.sdm_add_aurora_postgres
#   }
# }