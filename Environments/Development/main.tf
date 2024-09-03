provider "aws" {
    region = "us-east-2"
}


# Network Module
module "network" {
  source = "../../modules/network"

  vpc_cidr_block          = "10.0.0.0/16"
  private_db_subnet1_cidr = "10.0.1.0/24"
  private_db_subnet2_cidr = "10.0.2.0/24"
  availability_zone1      = "us-east-2a"
  availability_zone2      = "us-east-2b"
  vpc_name                = "vpc_fdp"
}


# RDS SG Module
module "rds_sg" {
  source = "../../modules/security_groups"

  vpc_id  = aws_vpc.vpc_fdp.id
  sg_name = var.sg_name

  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
