provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

######################################
# Create VPC for ECS cluster
######################################

resource "aws_vpc" "ecs_vpc" {
  cidr_block  = "${var.vpc_cidr_block}"
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
# Get availability zones list
######################################
data "aws_availability_zones" "available" {}

######################################
# Subnets
######################################

resource "aws_subnet" "ecs_public_sn" {
  count             = "${length(var.cidr_blocks)}"
  vpc_id            = "${aws_vpc.ecs_vpc.id}"
  cidr_block        = "${var.cidr_blocks[count.index]}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  tags        = {
    Name      = "${format("ecs-public-subnet-%03d", count.index+1)}"
  }
}


#######################################
# Routing Table for public Subnet
#######################################

resource "aws_route_table" "ecs_public_rt" {
  vpc_id        = "${aws_vpc.ecs_vpc.id}"
  route         = {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = "${aws_internet_gateway.ecs_igw.id}"
  }
  tags          = {
    Name        = "demo_ecs_public_rt" 
  }
}

#############################################
# Associate the routing table to pub subnet
#############################################

resource "aws_route_table_association" "ecs_route_to_subnet_asscn" {
  count           = "${length(var.cidr_blocks)}"

  subnet_id       = "${element(aws_subnet.ecs_public_sn.*.id, count.index)}"
  route_table_id  = "${aws_route_table.ecs_public_rt.id}"
}

#################################################################
# Create security group allow all public traffic to the service
#################################################################

resource "aws_security_group" "ecs_sg" {
  name        = "ecs_security_group_8443"
  description = "Security Group for demo ECS allow all public traffic to the service"
  vpc_id      = "${aws_vpc.ecs_vpc.id}"

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
