# Provider and Region
provider "aws" {
    region = "us-east-2"
}



# VPC
# Private Database Subnet 1
# Private Database Subnet 2
# Security Group for RDS Instances
# RDS Instance 1
# RDS Instance 2



# VPC
resource "aws_vpc" "vpc_fdp" {
    cidr_block = "10.0.0.0/16"
    
    tags = {
        Name = "vpc_fdp"
    }
}



# Private Database Subnet 1
resource "aws_subnet" "private_db_subnet1" {
    vpc_id = aws_vpc.vpc_fdp.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-2a"
    
    tags = {
        Name = "private_db_subnet1"
    }
}



# Private Database Subnet 2
resource "aws_subnet" "private_db_subnet2" {
    vpc_id = aws_vpc.vpc_fdp.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-2b"
    
    tags = {
        Name = "private_db_subnet2"
    }
}



# Security Group for RDS Instance
resource "aws_security_group" "sg_rds" {
    vpc_id = aws_vpc.vpc_fdp.id
    name = "sg_rds"
    
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}



# RDS Instance 1
resource "aws_db_instance" "rds_instance1" {
    allocated_storage = 20
    engine = "mysql"
    instance_class = "db.t3.micro"
    name = "rds_instance1"
    username = "admin2_fdp"
    password = "333Delivery!"
    vpc_security_group_ids = [aws_security_group.sg_rds.id]
    subnet_id = aws_subnet.private_db_subnet1.id
    skip_final_snapshot = false
    
    tags = {
        Name = "rds_instance1"
    }
}



# RDS Instance 2
resource "aws_db_instance" "rds_instance2" {
    allocated_storage = 20
    engine = "mysql"
    instance_class = "db.t3.micro"
    name = "rds_instance2"
    username = "admin1_fdp"
    password = "BBBDelivery!"
    vpc_security_group_ids = [aws_security_group.sg_rds.id]
    subnet_id = aws_subnet.private_db_subnet2.id
    skip_final_snapshot = false
    
    tags = {
        Name = "rds_instance2"
    }
}