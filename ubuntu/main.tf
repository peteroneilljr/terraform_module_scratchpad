#################
# Security Group
#################
resource "aws_security_group" "ubuntu" {
  name = var.server_name

  description = var.server_name
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
#################
# Create network interface to attach sdm resource
#################
resource "aws_network_interface" "ubuntu" {
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.ubuntu.id]

  tags = merge({ "Name" = "${var.server_name}" }, var.tags, )
}
resource "aws_eip" "ubuntu" {
  network_interface = aws_network_interface.ubuntu.id
}
resource "sdm_resource" "ubuntu" {
  ssh {
    name     = "tf-ubuntu"
    username = "ubuntu"
    hostname = aws_eip.ubuntu.public_dns
    port     = 22
  }
  provisioner "local-exec" {
    command = "sdm admin roles grant ${sdm_resource.ubuntu.ssh.0.name} NOC && echo SUCCESS"
  }
}
#################
# Create instance 
#################
resource "aws_instance" "ubuntu" {
  instance_type = var.instance_type
  monitoring    = var.monitoring
  key_name      = var.key_name
  ami           = data.aws_ami.ubuntu.image_id

  user_data = <<ADDSDMKEY
#!/bin/bash
echo "${sdm_resource.ubuntu.ssh.0.public_key}" >> "/home/${local.username}/.ssh/authorized_keys"
ADDSDMKEY

  network_interface {
    network_interface_id = aws_network_interface.ubuntu.id
    device_index         = 0
  }
  tags = merge({ "Name" = "${var.server_name}" }, var.tags, )
}


#################
# ignore this is for an sdm example
#################
# resource "sdm_resource_attachment" "ubuntu" {
#   ssh_key {}
# }
# resource "aws_instance" "ubuntu" {
#   instance_type               = var.instance_type
#   key_name                    = var.key_name
#   ami                         = data.aws_ami.ubuntu.image_id

#   user_data                   = <<ADDSDMKEY
# #!/bin/bash
# echo "${sdm_resource_attachment.ubuntu.ssh_key}" >> "/home/${local.username}/.ssh/authorized_keys"
# ADDSDMKEY
# }

# resource "sdm_resource" "ubuntu" {
#   ssh {
#     name          = "tf-ubuntu"
#     username      = "ubuntu"
#     hostname      = aws_eip.ubuntu.public_dns
#     port          = 22
#     public_key    = sdm_resource_attachment.ubuntu.ssh_key
#   }
# }


