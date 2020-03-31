
resource "aws_instance" "windows_server" {
  instance_type               = "t3.medium"
  monitoring                  = var.monitoring
  get_password_data           = var.get_password_data
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  ami                         = data.aws_ami.windows_server.image_id
  user_data                   = local.user_data
  vpc_security_group_ids      = [aws_security_group.windows_server.id]
  tags                        = merge({ "Name" = "${var.server_name}" }, var.default_tags, )
}

resource "aws_security_group" "windows_server" {
  name        = var.server_name
  description = var.server_name
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   from_port   = 389
  #   to_port     = 389
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   from_port   = 636
  #   to_port     = 636
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   from_port   = 49443
  #   to_port     = 49443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   from_port   = 49152
  #   to_port     = 65535
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ "Name" = "${var.server_name}" }, var.default_tags, )
}