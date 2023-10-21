variable "vpc_cidr" {
  default = "10.100.0.0/16"
}

# Create vpc
resource "aws_vpc" "operator" {
  cidr_block           = var.vpc_cidr 
  enable_dns_hostnames = true 
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "operator_vpc"
  }
}

data "aws_availability_zones" "available" {}

# Create Internet Gateway
resource "aws_internet_gateway" "operator-igw" {
  vpc_id = aws_vpc.operator.id

  tags = {
    Name = "operator_Internet_Gateway"
  }
}

resource "aws_main_route_table_association" "operator" {
  vpc_id         = aws_vpc.operator.id
  route_table_id = aws_route_table.operator-rt.id
}

# Route Table
resource "aws_route_table" "operator-rt" {
  vpc_id = aws_vpc.operator.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.operator-igw.id
  }

  tags = { 
    Name = "OperatorLab_Routing_Table"
  }
}

output "vpc_id" {
  value = aws_vpc.operator.id
}

output "vpc_prefix" {
  value = aws_vpc.operator.cidr_block
}

variable "ad_subnet_name" {
  default = "ad_subnet"
}

variable "ad_subnet_prefix" {
  default = "10.100.10.0/24"
}
    
# Create the ad_subnet subnet
resource "aws_subnet" "ad_subnet" {
  
  vpc_id  = aws_vpc.operator.id
  cidr_block              = var.ad_subnet_prefix
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  
  tags = {
    Name = var.ad_subnet_name
  }
  depends_on = [aws_vpc.operator]
}

output "ad_subnet_id" {
  value = aws_subnet.ad_subnet.id
}

output "ad_subnet_prefix" {
  value = aws_subnet.ad_subnet.cidr_block
}

variable "user_subnet_name" {
  default = "user_subnet"
}

variable "user_subnet_prefix" {
  default = "10.100.20.0/24"
}
    
# Create the user_subnet subnet
resource "aws_subnet" "user_subnet" {
  
  vpc_id  = aws_vpc.operator.id
  cidr_block              = var.user_subnet_prefix
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  
  tags = {
    Name = var.user_subnet_name
  }
  depends_on = [aws_vpc.operator]
}

output "user_subnet_id" {
  value = aws_subnet.user_subnet.id
}

output "user_subnet_prefix" {
  value = aws_subnet.user_subnet.cidr_block
}

variable "siem_subnet_name" {
  default = "siem_subnet"
}

variable "siem_subnet_prefix" {
  default = "10.100.30.0/24"
}
    
# Create the siem_subnet subnet
resource "aws_subnet" "siem_subnet" {
  
  vpc_id  = aws_vpc.operator.id
  cidr_block              = var.siem_subnet_prefix
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  
  tags = {
    Name = var.siem_subnet_name
  }
  depends_on = [aws_vpc.operator]
}

output "siem_subnet_id" {
  value = aws_subnet.siem_subnet.id
}

output "siem_subnet_prefix" {
  value = aws_subnet.siem_subnet.cidr_block
}

variable "attack_subnet_name" {
  default = "attack_subnet"
}

variable "attack_subnet_prefix" {
  default = "10.100.40.0/24"
}
    
# Create the attack_subnet subnet
resource "aws_subnet" "attack_subnet" {
  
  vpc_id  = aws_vpc.operator.id
  cidr_block              = var.attack_subnet_prefix
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  
  tags = {
    Name = var.attack_subnet_name
  }
  depends_on = [aws_vpc.operator]
}

output "attack_subnet_id" {
  value = aws_subnet.attack_subnet.id
}

output "attack_subnet_prefix" {
  value = aws_subnet.attack_subnet.cidr_block
}
