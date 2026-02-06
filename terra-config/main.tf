#Data Sources
data "aws_vpc" "selected" {
  id = var.vpc_id
}
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}
# Keypair creation
resource "tls_private_key" "ansible_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "ansible_keypair" {
  key_name   = "ansible_keypair"
  public_key = tls_private_key.ansible_keypair.public_key_openssh
}
resource "local_file" "ansible_private_keypair" {
  filename        = "${path.module}/../ansible/ansible_keypair.pem"
  content         = tls_private_key.ansible_keypair.private_key_pem
  file_permission = "0400"
}

# Security Group for EC2
resource "aws_security_group" "controller" {
  name        = "controller-sg-${var.environment}"
  description = "Controller security group"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  ingress {
    from_port   = 80
    to_port     = 80
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
resource "aws_security_group" "nodes" {
  name        = "nodes-sg-${var.environment}"
  description = "Nodes security group"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  ingress {
    from_port   = 80
    to_port     = 80
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
# Controller
resource "aws_instance" "controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ansible_keypair.key_name
  subnet_id = data.aws_subnets.public.ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.controller.id]
  iam_instance_profile = aws_iam_instance_profile.ansible_instance_profile.name
  user_data              = file("${path.module}/userdata-controller.sh")

  tags = {
    Name = "ansible-controller"
    Role = "controller"
  }
}

# Environment Nodes
locals {
envs = ["dev", "dev", "stage", "stage", "prod", "prod"]
}

resource "aws_instance" "nodes" {
  count                  = 6
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ansible_keypair.key_name
  subnet_id              = data.aws_subnets.public.ids[count.index % length(data.aws_subnets.public.ids)]
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.nodes.id]
  user_data              = file("${path.module}/userdata-node.sh")

  tags = {
    Name        = "app-${local.envs[count.index]}-${count.index}"
    Role        = "app"
    Environment = local.envs[count.index]
  }
}


# resource "aws_instance" "nodes" {
#   ami                    = data.aws_ami.ubuntu.id
#   count                  = 6
#   instance_type          = var.instance_type
#   key_name               = aws_key_pair.ansible_keypair.key_name
#   associate_public_ip_address = true
#   subnet_id = data.aws_subnets.public.ids[count.index % length(data.aws_subnets.public.ids)]
#   vpc_security_group_ids = [aws_security_group.nodes.id]
#   user_data              = file("${path.module}/userdata-node.sh")

#  tags = {
#    Name = "app-${local.envs[count.index]}-${count.index}"
#    Role = "app"
#    Environment = local.envs[count.index]
#  }
# }
