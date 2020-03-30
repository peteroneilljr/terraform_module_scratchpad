#################
# Create strongDM gateway and store token
#################
resource "sdm_node" "sdm_gateway" {
  gateway {
    name           = var.sdm_gateway_name
    listen_address = "${aws_eip.sdm_gateway.public_dns}:${var.gateway_listen_port}"
    bind_address   = "0.0.0.0:${var.gateway_listen_port}"
  }
}
resource "aws_ssm_parameter" "sdm_gateway" {
  name  = "/strongdm/gateways/${var.sdm_gateway_name}/token"
  type  = "String"
  value = "${sdm_node.sdm_gateway.gateway.0.token}"
  tags  = merge({ "Name" = "${var.sdm_gateway_name}" }, var.tags, )
}
#################
# Instance configuration 
#################
resource "aws_eip" "sdm_gateway" {
  network_interface = aws_network_interface.sdm_gateway.id
}
resource "aws_network_interface" "sdm_gateway" {
  subnet_id       = var.deploy_subnet_id
  security_groups = [aws_security_group.sdm_gateway.id]

  tags = merge({ "Name" = "${var.sdm_gateway_name}" }, var.tags, )
}
resource "aws_instance" "sdm_gateway" {
  instance_type = "t3.medium"
  ami           = data.aws_ami.amazon_linux_2.image_id
  user_data     = <<USERDATA
#!/bin/bash -xe
curl -J -O -L https://app.strongdm.com/releases/cli/linux && unzip sdmcli* && rm -f sdmcli*
sudo ./sdm install --relay --token="${aws_ssm_parameter.sdm_gateway.value}"
USERDATA
  key_name      = var.ssh_key
  monitoring    = true

  credit_specification {
    # Prevents CPU throttling and potential performance issues
    cpu_credits = "unlimited"
  }
  network_interface {
    network_interface_id = aws_network_interface.sdm_gateway.id
    device_index         = 0
  }

  tags = merge({ "Name" = "${var.sdm_gateway_name}" }, var.tags, )
}
#################
# Security Group
#################
resource "aws_security_group" "sdm_gateway" {
  name = var.sdm_gateway_name
  tags = merge({ "Name" = "${var.sdm_gateway_name}" }, var.tags,
  )

  description = "Open port ${var.gateway_listen_port} for strongDM access"
  vpc_id      = var.deploy_vpc_id

  ingress {
    from_port   = var.gateway_listen_port
    to_port     = var.gateway_listen_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "sdm_gateway" {
  count             = var.ssh_access ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_source]
  security_group_id = aws_security_group.sdm_gateway.id
}
