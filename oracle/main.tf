
#################
# Oracle DB on RDS
#################

resource "aws_db_instance" "rds" {
  allocated_storage           = var.storage_size
  engine                      = var.db_engine
  publicly_accessible         = var.publicly_accessible
  engine_version              = var.db_engine_version
  identifier                  = var.db_identifier
  instance_class              = var.db_instance_class
  skip_final_snapshot         = var.db_skip_final
  allow_major_version_upgrade = var.db_auto_upgrade
  auto_minor_version_upgrade  = var.db_auto_upgrade
  username                    = var.admin_username
  password                    = local.password
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
resource "sdm_resource" "oracle" {
  count = var.create_sdm ? 1 : 0
  oracle {
    name          = var.db_identifier
    hostname      = aws_db_instance.rds.address
    database      = aws_db_instance.rds.name
    username      = aws_db_instance.rds.username
    password      = aws_db_instance.rds.password
    port          = var.db_port
    tls_required  = true
    port_override = -1
  }
  lifecycle {
    ignore_changes = [
      oracle[0].password,
      oracle[0].port_override
    ]
  }
}