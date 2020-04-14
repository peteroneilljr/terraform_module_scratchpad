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
      oracle.0.password,
      oracle.0.port_override
    ]
  }
}
resource "sdm_role_grant" "oracle" {
  count = length(var.sdm_role_ids)

  role_id  = var.sdm_role_ids[count.index]
  resource_id = sdm_resource.oracle.0.id
}