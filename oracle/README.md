# Aurora module

**sample**
~~~
module "oracle12" {
  source              = "./modules/oracle"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.public_subnets
  db_engine           = "Oracle-ee"
  db_engine_version   = "12.2"

  # optionals
  db_identifier       = "oracle12"
  default_tags        = var.default_tags

  create_sdm = true
}

output "oracle12_endpoint" {
  value = module.oracle12.endpoint
}

module "oracle11_peter" {
  source            = "./modules/oracle"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnets
  db_engine         = "Oracle-ee"
  db_engine_version = "11.2"

  # optionals
  db_identifier       = "oracle11peter"
  default_tags        = var.default_tags

  create_sdm = true
}
output "aws_oracle_11_peter" {
  value = module.oracle11_peter.endpoint
}

# Full
module "oracle11_peter" {
  source            = "./modules/oracle"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnets
  db_engine         = "Oracle-ee"
  db_engine_version = "11.2"

  # optionals
  publicly_accessible = true
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  db_count            = 1
  db_auto_upgrade     = false
  db_identifier       = "oracle11peter"
  db_instance_class   = "db.m4.large"
  db_skip_final       = true
  db_port             = 1521
  default_tags        = var.default_tags

  create_sdm = true
}
output "aws_oracle_11_peter" {
  value = module.oracle11_peter.endpoint
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