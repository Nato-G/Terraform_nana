terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {
  
}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my-subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-route-table.id
}

resource "aws_security_group" "my-sg" {
  name = "my-sg"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name: "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

# to check if the ami is correct - find it firsl and run terraform plan
output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_instance" "my-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.my-subnet.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "server-key-pair"
  
  # runs only once when initializing the instance 
  # user_data = file("entry-script.sh")
  user_data = <<EOF
                    #!/bin/bash
                    sudo yum update -y && sudo yum install -y docker
                    sudo systemctl start docker 
                    sudo usermode -aG docker ec2-user
                    docker run -p 8080:80 nginx
                EOF
  tags = {
    Name: "${var.env_prefix}-server"
  }  
}




#using fetched data and creating the subnet in it 
# data "aws_vpc" "existing_vpc" {
#   default = true
# }
# resource "aws_subnet" "dev-subnet-2" {
#   vpc_id = data.aws_vpc.existing_vpc
#   cidr_block = "172.31.48.0/20"
#   availability_zone = "eu-north-1a"
# }
   


