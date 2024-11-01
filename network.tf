
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Create vpc
resource "aws_vpc" "tamnt1-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "tamnt1-vpc"
  }
}
# Create internet gateway
resource "aws_internet_gateway" "tamnt1-igw" {
  vpc_id = aws_vpc.tamnt1-vpc.id
  tags = {
    Name = "tamnt1-igw"
  }
}



# Create public route table
resource "aws_route_table" "tamnt1-rtb-public" {
  vpc_id = aws_vpc.tamnt1-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tamnt1-igw.id
  }
  tags = {
    Name = "tamnt1-rtb-public"
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet_us-east-2a" {
  vpc_id                  = aws_vpc.tamnt1-vpc.id
  cidr_block              = var.subnet_cidr_block[0] # 10.0.1.0/24
  availability_zone       = var.availability_zone[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_us-east-2b" {
  vpc_id                  = aws_vpc.tamnt1-vpc.id
  cidr_block              = var.subnet_cidr_block[1] # 10.0.2.0/24
  availability_zone       = var.availability_zone[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Links public subnets with route table
resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_us-east-2a.id
  route_table_id = aws_route_table.tamnt1-rtb-public.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_subnet_us-east-2b.id
  route_table_id = aws_route_table.tamnt1-rtb-public.id
}


output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = [aws_subnet.public_subnet_us-east-2a.id, aws_subnet.public_subnet_us-east-2b.id]
}


# Create  Elastic IP
resource "aws_eip" "nat_eip" {
  domain   = "vpc"
  instance = aws_instance.nat_instance.id
  tags = {
    Name = "tamnt1-nat-eip"
  }
}

# Create private route table with NAT instance
resource "aws_route_table" "tamnt1-rtb-private" {
  vpc_id = aws_vpc.tamnt1-vpc.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id

  }

  tags = {
    Name = "tamnt1-rtb-private"
  }
}

# Create private subnet
resource "aws_subnet" "private_subnet_us-east-2a" {
  vpc_id            = aws_vpc.tamnt1-vpc.id
  cidr_block        = var.subnet_cidr_block[2] # 10.0.3.0/24
  availability_zone = var.availability_zone[0]
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_us-east-2b" {
  vpc_id            = aws_vpc.tamnt1-vpc.id
  cidr_block        = var.subnet_cidr_block[3] # 10.0.4.0/24
  availability_zone = var.availability_zone[1]
  tags = {
    Name = "private-subnet-2"
  }
}

# Link private subnets with route table
resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private_subnet_us-east-2a.id
  route_table_id = aws_route_table.tamnt1-rtb-private.id
}

resource "aws_route_table_association" "private_association_2" {
  subnet_id      = aws_subnet.private_subnet_us-east-2b.id
  route_table_id = aws_route_table.tamnt1-rtb-private.id
}


