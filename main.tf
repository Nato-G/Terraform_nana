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

variable "subnet_cidr_block" {
  description = "subnet cidr block"
  default = "10.0.10.0/24"
  type = string
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
}

resource "aws_vpc" "dev-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "dev-vpc"
    vpc_env: "dev"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id = aws_vpc.dev-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "eu-north-1a"
  tags = {
    Name: "subnet-dev-1"
  }
}

# to show the output value specified after the applied changes, helps when bunch of id, ips needed. 
output "dev-vpc_id" {
  value = aws_vpc.dev-vpc.id
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
   


