# VPC
resource "aws_vpc" "vpc_fdp" {
    cidr_block = var.vpc_cidr_block
    
    tags = {
        Name = var.vpc_name
    }
}

# Private Database Subnet 1
resource "aws_subnet" "private_db_subnet1" {
    vpc_id            = aws_vpc.vpc_fdp.id
    cidr_block        = var.private_db_subnet1_cidr
    availability_zone = var.availability_zone1
    
    tags = {
        Name = "private_db_subnet1"
    }
}

# Private Database Subnet 2
resource "aws_subnet" "private_db_subnet2" {
    vpc_id            = aws_vpc.vpc_fdp.id
    cidr_block        = var.private_db_subnet2_cidr
    availability_zone = var.availability_zone2
    
    tags = {
        Name = "private_db_subnet2"
    }
}
