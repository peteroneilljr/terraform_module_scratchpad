#################
# Locals
#################
locals {
  create_relay   =   local.relay_count > 0 ? true : false
  create_gateway = local.gateway_count > 0 ? true : false

  gateway_count = length(var.deploy_gw_subnet_ids)
  relay_count   = length(var.deploy_relay_subnet_ids)
  node_count    = length(var.deploy_gw_subnet_ids) + length(var.deploy_relay_subnet_ids)

  node_name_list  = concat(sdm_node.gateway.*.gateway.0.name, sdm_node.relay.*.relay.0.name)
  node_token_list = concat(sdm_node.gateway.*.gateway.0.token, sdm_node.relay.*.relay.0.token)
  subnet_list     = concat(var.deploy_gw_subnet_ids, var.deploy_relay_subnet_ids)
}
#################
# Create strongDM gateway and store token
#################
resource "sdm_node" "gateway" {
  count = local.gateway_count

  gateway {
    name           = "${var.sdm_node_name}-gateway-${count.index}"
    listen_address = "${var.disable_dns ? aws_eip.node[count.index].public_ip : aws_eip.node[count.index].public_dns}:${var.gateway_listen_port}"
    bind_address   = "0.0.0.0:${var.gateway_listen_port}"
  }
}
resource "sdm_node" "relay" {
  count = local.relay_count

  relay {
    name = "${var.sdm_node_name}-relay-${count.index}"
  }
}

resource "aws_ssm_parameter" "node" {
  count = local.node_count

  type  = "SecureString"
  value = local.node_token_list[count.index]
  name  = "/strongdm/node/${local.node_name_list[count.index]}/token"

  overwrite = true
  key_id = var.customer_key

  tags  = merge({ "Name" = "${local.node_name_list[count.index]}" }, var.tags, )
}
#################
# Instance configuration 
#################
resource "aws_eip" "node" {
  count = local.gateway_count
  network_interface = aws_network_interface.node[count.index].id
}
resource "aws_network_interface" "node" {
  count = local.gateway_count

  subnet_id       = local.subnet_list[count.index]
  security_groups = [aws_security_group.node[0].id]

  tags = merge({ "Name" = "${var.sdm_node_name}-nic-${count.index}" }, var.tags, )
}
resource "aws_instance" "node" {
  count = local.node_count

  ami           = data.aws_ami.amazon_linux_2.image_id
  instance_type = var.dev_mode ? "t3.micro" : "t3.medium"

  user_data = <<USERDATA
#!/bin/bash -xe
curl -J -O -L https://app.strongdm.com/releases/cli/linux && unzip sdmcli* && rm -f sdmcli*
sudo ./sdm install --relay --token="${aws_ssm_parameter.node[count.index].value}"
USERDATA

  key_name   = var.ssh_key
  monitoring = var.detailed_monitoiring

  credit_specification {
    # Prevents CPU throttling and potential performance issues with Gateway
    cpu_credits = "unlimited"
  }

  # Relay Attributes 
  subnet_id              = count.index > local.gateway_count ? local.subnet_list[count.index] : null
  vpc_security_group_ids = count.index > local.gateway_count ? [aws_security_group.node[1].id] : null

  # Gateway Attributes 
  dynamic "network_interface" {
    for_each = count.index < local.gateway_count ? [1] : []
    content {
      network_interface_id = aws_network_interface.node[count.index].id
      device_index         = 0
    }
  }

  lifecycle {

    # Prevents Instance from respawning when Amazon Linux 2 is updated
    ignore_changes = [ami]

    # Used to prevent EIP from failing to associate 
    # https://github.com/terraform-providers/terraform-provider-aws/issues/2689
    create_before_destroy = true
  }

  tags = merge({ "Name" = "${local.node_name_list[count.index]}" }, var.tags, )
}
#################
# Security Group
#################
resource "aws_security_group" "node" {
  count = local.create_relay ? 2 : local.create_gateway ? 1 : 0
  # Note: If deploying only relays, a gateway is still created with no resources assigned to it.

  name        = count.index < 1 ? "${var.sdm_node_name}-gateways" : "${var.sdm_node_name}-relays"
  description = count.index < 1 ? "Open port ${var.gateway_listen_port} for strongDM access" : "Egress only security group for strongDM relay"

  vpc_id = var.deploy_vpc_id

  dynamic "ingress" {
    for_each = count.index < 1 ? [1] : []
    content {
      from_port   = var.gateway_listen_port
      to_port     = var.gateway_listen_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.ssh_access ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_source]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  timeouts {
    delete = "2m"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = merge({ "Name" = "${var.sdm_node_name}-node" }, var.tags, )
}