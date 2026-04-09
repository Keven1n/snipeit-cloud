provider "aws" {
  region = var.aws_region
}

# Obtém o IP atual de quem executa o script
data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

# Busca a AMI oficial do Ubuntu 22.04 LTS (Jammy)
data "aws_ami" "ubuntu_22_04" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Gera chave privada local e no formato PEM
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Cria Key Pair na AWS
resource "aws_key_pair" "snipeit_key" {
  key_name   = "snipeit-ec2-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Salva a chave privada localmente para ser usada pelo Ansible
resource "local_sensitive_file" "private_key_file" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/../ansible/snipeit-key.pem"
  file_permission = "0400"
}

# Cria Security Group (SSH pro seu IP e HTTP livre)
resource "aws_security_group" "snipeit_sg" {
  name        = "snipeit-web-sg"
  description = "Allow HTTP inbound and SSH from my IP"

  ingress {
    description = "SSH from my own IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  ingress {
    description = "HTTP from anywhere"
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

# Lança a Instância EC2 t2.micro
resource "aws_instance" "snipeit_server" {
  ami           = data.aws_ami.ubuntu_22_04.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.snipeit_key.key_name

  vpc_security_group_ids      = [aws_security_group.snipeit_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "SnipeIT-Server"
  }
}
