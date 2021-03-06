# Aurora module

**sample**
~~~
module "aurora" {
  source              = "./modules/aurora"
  vpc_id              = aws_vpc.peter_vpc.id
  subnet_ids          = aws_subnet.peter_public_subnet.*.id
  db_engine           = "aurora-postgresql"
  db_engine_mode      = "serverless"
  db_engine_version   = "10.7"

  # optionals
  publicly_accessible = true
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  db_count            = 1
  db_auto_upgrade     = false
  db_identifier       = "auroradb"
  db_instance_class   = "db.r5.large"
  db_skip_final       = true
  db_port             = 5432
  db_backtrack        = 0
  default_tags        = var.default_tags

  sdm_admin_token     = var.sdm_admin_full
}

output "aurora_endpoint" {
  value = module.aurora.endpoint
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