resource "sdm_node" "gateway" {
  gateway {
    name           = "gw1"
    listen_address = "sdmlocal:5000"
    bind_address   = "0.0.0.0:5000"
  }
}

resource "sdm_node" "relay" {
  gateway {
    name           = "relay1"
  }
}

#################
# Security Groups
#################
resource "aws_security_group" "sdm_gateway_sg" {
  name = "sdm_gateway_sg"
  tags = merge(
    { "Name" = "sdm_gateway_sg" },
    var.default_tags,
  )

  description = "Allow 22 and sdm listening port"
  vpc_id      = aws_vpc.peter_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.sdm_listening_port
    to_port     = var.sdm_listening_port
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

#################
# AWS Instance
#################

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

variable "sdm_listening_port" {
  description = "The port number clients will connect to the gateway on. This port will be added as a input rule for the security group"
  type        = number
  default     = 5000
}

variable "sdm_admin_token" {
  description = "Serves as the authentication credentials to register the gateway to your organization. This token needs create:relay privileges"
  type        = string
  default     = "strongDM_admin_token"
}

resource "aws_security_group" "sdm_gateway_sg" {
  name = "sdm_gateway_sg"
  tags = merge(
    { "Name" = "sdm_gateway_sg" },
    var.default_tags,
  )

  description = "Allow 22 and sdm listening port"
  vpc_id      = aws_vpc.peter_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.sdm_listening_port
    to_port     = var.sdm_listening_port
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

resource "aws_instance" "sdm_gateway" {
  count         = length(aws_subnet.peter_public_subnet)
  instance_type = "t3.micro"
  ami           = data.aws_ami.amazon_linux_2.image_id
  user_data     = data.template_file.sdm_gw.rendered
  key_name      = aws_key_pair.sdm_key.key_name
  monitoring    = true

  iam_instance_profile = aws_iam_instance_profile.sdm_gateway.name

  # associate_public_ip_address = true
  depends_on             = [aws_internet_gateway.peter_vpc_igw]
  vpc_security_group_ids = [aws_security_group.sdm_gateway_sg.id]
  subnet_id              = aws_subnet.peter_public_subnet[count.index].id

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = merge({ "Name" = "sdm_gateway_${count.index + 1}" }, var.default_tags, )
}

#################
# CloudWatch Alarms
#################

resource "aws_cloudwatch_metric_alarm" "sdm_gw_cpu" {
  count = length(aws_instance.sdm_gateway)

  alarm_name                = "cpu_over_80_${aws_instance.sdm_gateway[count.index].tags.Name}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This SDM gateway is overutilized"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.sdm_gateway[count.index].id
  }
}

output "sdm_gateways" {
  value = {
    for instance in aws_instance.sdm_gateway :
    instance.tags.Name => instance.public_ip
  }
}

