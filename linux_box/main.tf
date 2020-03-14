
variable "ubuntu_account_number" {
  default = "099720109477"
}
data "aws_ami" "ubuntu-18_04" {
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ami" "ubuntu" {
  # aws ec2 describe-images --filters 'Name=state,Values=available' 'Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-xenial-16*' --region 'us-west-2' --query 'reverse(sort_by(Images, &CreationDate))[:1]' --output json
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ami" "ubuntu14" {
  # aws ec2 describe-images --filters 'Name=state,Values=available' 'Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-xenial-16*' --region 'us-west-2' --query 'reverse(sort_by(Images, &CreationDate))[:1]' --output json
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server*"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}


resource "aws_instance" "ubuntu" {
  instance_type               = var.instance_type
  monitoring                  = var.monitoring
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name
  ami                         = data.aws_ami.ubuntu14.image_id
  #   user_data                   = data.template_file.sdm_auto_reg_server_ubuntu.rendered

  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  tags = merge({ "Name" = "${var.server_name}" }, var.tags, )
}

resource "aws_security_group" "ssh_access" {
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

output "ssh_login" {
  value = "ssh -i '${var.private_key_path}' ubuntu@${aws_instance.ubuntu.public_ip}"
}

