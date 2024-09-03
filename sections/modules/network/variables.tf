variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "private_db_subnet1_cidr" {
  description = "The CIDR block for the first private database subnet"
  type        = string
}

variable "private_db_subnet2_cidr" {
  description = "The CIDR block for the second private database subnet"
  type        = string
}

variable "availability_zone1" {
  description = "The availability zone for the first subnet"
  type        = string
}

variable "availability_zone2" {
  description = "The availability zone for the second subnet"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}
