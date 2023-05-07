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

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.my-vpc.id
}

module "myapp-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.my-vpc.id
  my_ip =  var.my_ip
  env_prefix = var.env_prefix
  image_name = var.image_name
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet.subnet.id
  avail_zone = var.avail_zone
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
   


