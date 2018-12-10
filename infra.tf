provider "aws" {
  profile = "otec"
  region  = "eu-central-1"
}

######################################
# Create VPC for ECS cluster
######################################

resource "aws_vpc" "ecs_vpc" {
  cidr_block  = "10.0.0.0/16"
  tags        = {
    Name      = "demo_ecs_vpc"
  }
}

######################################
# Add IGW for VPC 
######################################

resource "aws_internet_gateway" "ecs_igw" {
  vpc_id  = "${aws_vpc.ecs_vpc.id}"
  tags    = {
    Name  = "demo_ecs_igw"
  }  
}

######################################
# Public subnet
######################################

resource "aws_subnet" "ecs_public_subnet" {
  vpc_id            = "${aws_vpc.ecs_vpc.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-central-1a" 
  tags        = {
    Name      = "demo_ecs_pub_subnet"
  }
}

#######################################
# Routing Table for public Subnet
#######################################

resource "aws_route_table" "ecs_publicsubnet_route_table" {
  vpc_id        = "${aws_vpc.ecs_vpc.id}"
  route         = {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = "${aws_internet_gateway.ecs_igw.id}"
  }
  tags          = {
    Name        = "demo_ecs_public_route_table" 
  }
}

#############################################
# Associate the routing table to pub subnet
#############################################

resource "aws_route_table_association" "ecs_route_to_subnet_asscn" {
  subnet_id       = "${aws_subnet.ecs_public_subnet.id}"
  route_table_id  = "${aws_route_table.ecs_publicsubnet_route_table.id}"
}

############################################
# Create security group for ALB
############################################

resource "aws_security_group" "ecs_sg" {
  name        = "ecs_security_group"
  description = "Security Group for demo ECS"
  vpc_id      = "${aws_vpc.ecs_vpc.id}" 
}
