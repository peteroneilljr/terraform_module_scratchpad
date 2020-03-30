# Aurora module

**sample**
~~~
module "oracle12" {
  source              = "./modules/RDS"
  vpc_id              = aws_vpc.peter_vpc.id
  subnet_ids          = aws_subnet.peter_public_subnet.*.id
  db_engine           = "Oracle-ee"
  db_engine_version   = "12.2"

  # optionals
  publicly_accessible = true
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  db_count            = 1
  db_auto_upgrade     = false
  db_identifier       = "oracle12"
  db_instance_class   = "db.m4.large"
  db_skip_final       = true
  db_port             = 1521
  default_tags        = var.default_tags

  # sdm_admin_token     = var.sdm_admin_full
}

output "oracle12_endpoint" {
  value = module.oracle12.endpoint
}

module "aurora" {
  source              = "./modules/aurora"
  vpc_id              = aws_vpc.peter_vpc.id
  subnet_ids          = aws_subnet.peter_public_subnet.*.id
  publicly_accessible = true
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  db_count            = 1
  db_engine           = "oracle"
  # db_engine_mode      = "serverless"
  db_engine_version   = "19.0.0.0"
  db_auto_upgrade     = false
  db_identifier       = "oracle"
  db_instance_class   = "db.r5.large"
  db_skip_final       = true
  db_port             = 1521
  db_backtrack        = 0
  default_tags        = var.default_tags

  sdm_admin_token = var.sdm_admin_full
}

output "aurora_endpoint" {
  value = module.aurora.endpoint
}


module "oracle11" {
  source              = "./modules/RDS"
  vpc_id              = aws_vpc.peter_vpc.id
  subnet_ids          = aws_subnet.peter_public_subnet.*.id
  db_engine           = "Oracle-ee"
  db_engine_version   = "11.2"

  # optionals
  publicly_accessible = true
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  db_count            = 1
  db_auto_upgrade     = false
  db_identifier       = "oracle11"
  db_instance_class   = "db.m4.large"
  db_skip_final       = true
  db_port             = 1521
  default_tags        = var.default_tags

  # sdm_admin_token     = var.sdm_admin_full
}

output "oracle11_endpoint" {
  value = module.oracle11.endpoint
}

~~~
Available DB_engine

    aurora (for MySQL 5.6-compatible Aurora)
    aurora-mysql (for MySQL 5.7-compatible Aurora)
    aurora-postgresql
    mariadb
    mysql
    oracle-ee
    oracle-se2
    oracle-se1
    oracle-se
    postgres
    sqlserver-ee
    sqlserver-se
    sqlserver-ex
    sqlserver-web

[docs-aws](https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html)

### Notes
Serverless is only compatible with specific versions
[AWS Doc](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.html#aurora-serverless.limitations)