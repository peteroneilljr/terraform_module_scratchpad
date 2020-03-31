#################
# Create strongDM gateway and store token
#################
resource "sdm_node" "gateway" {
  count = length(var.deploy_gw_subnet_ids)

  gateway {
    name           = "${var.sdm_node_name}-gateway-${count.index}"
    listen_address = "${aws_eip.node[count.index].public_dns}:${var.gateway_listen_port}"
    bind_address   = "0.0.0.0:${var.gateway_listen_port}"
  }
}
resource "sdm_node" "relay" {
  count = length(var.deploy_relay_subnet_ids)

  relay {
    name = "${var.sdm_node_name}-relay-${count.index}"
  }
}
locals {
  node_name_list  = concat(sdm_node.gateway.*.gateway.0.name, sdm_node.relay.*.relay.0.name)
  node_token_list = concat(sdm_node.gateway.*.gateway.0.token, sdm_node.relay.*.relay.0.token)
  subnet_list     = concat(var.deploy_gw_subnet_ids, var.deploy_relay_subnet_ids)
}

resource "aws_ssm_parameter" "node" {
  count = length(local.node_name_list)

  name  = "/strongdm/node/${local.node_name_list[count.index]}/token"
  type  = "String"
  value = local.node_token_list[count.index]
  tags  = merge({ "Name" = "${local.node_name_list[count.index]}" }, var.tags, )
}
#################
# Instance configuration 
#################
resource "aws_eip" "node" {
  count = length(var.deploy_gw_subnet_ids) + length(var.deploy_relay_subnet_ids)

  network_interface = aws_network_interface.node[count.index].id
}
resource "aws_network_interface" "node" {
  count = length(var.deploy_gw_subnet_ids) + length(var.deploy_relay_subnet_ids)

  subnet_id       = local.subnet_list[count.index]
  security_groups = [count.index <= length(var.deploy_gw_subnet_ids) ? aws_security_group.gateway[0].id : aws_security_group.relay[0].id]

  tags = merge({ "Name" = "${var.sdm_node_name}-node-${count.index}" }, var.tags, )
}
resource "aws_instance" "node" {
  count = length(local.node_name_list)

  instance_type = var.dev_mode ? "t3.micro" : "t3.medium"
  ami           = data.aws_ami.amazon_linux_2.image_id
  user_data     = <<USERDATA
#!/bin/bash -xe
curl -J -O -L https://app.strongdm.com/releases/cli/linux && unzip sdmcli* && rm -f sdmcli*
sudo ./sdm install --relay --token="${aws_ssm_parameter.node[count.index].value}"
USERDATA
  key_name      = var.ssh_key
  monitoring    = true

  credit_specification {
    # Prevents CPU throttling and potential performance issues
    cpu_credits = "unlimited"
  }
  network_interface {
    network_interface_id = aws_network_interface.node[count.index].id
    device_index         = 0
  }
  lifecycle {
    ignore_changes = [ami]
  }
  tags = merge({ "Name" = "${local.node_name_list[count.index]}" }, var.tags, )
}
#################
# Security Group
#################
resource "aws_security_group" "gateway" {
  count = length(var.deploy_gw_subnet_ids) > 0 ? 1 : 0

  name = "${var.sdm_node_name}-gateways"
  tags = merge({ "Name" = "${var.sdm_node_name}" }, var.tags,
  )

  description = "Open port ${var.gateway_listen_port} for strongDM access"
  vpc_id      = var.deploy_vpc_id

  ingress {
    from_port   = var.gateway_listen_port
    to_port     = var.gateway_listen_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.ssh_access ? [var.ssh_source] : []
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
    delete = "1m"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "relay" {
  count = length(var.deploy_relay_subnet_ids) > 0 ? 1 : 0

  name = "${var.sdm_node_name}-relays"
  tags = merge({ "Name" = "${var.sdm_node_name}" }, var.tags,
  )

  description = "Egress only security group for strongDM relay"
  vpc_id      = var.deploy_vpc_id

  dynamic "ingress" {
    for_each = var.ssh_access ? [var.ssh_source] : []
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
    delete = "1m"
  }
  lifecycle {
    create_before_destroy = true
  }
}

