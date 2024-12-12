###############################
###REGION VARIABLES###
###############################
variable "aws_region" {
  description = "the aws region where resources will be deployed"
  type        = string
  sensitive   = true
}

################################
#S3 BUCKET VARIABLES
################################
variable "s3_bucket_name" {
  description = "The name of the s3 bucket that will host the web application"
  type        = string
  sensitive   = true
}

#################################
##### DATABASE VARIABLES####
#################################
variable "db_name1" {
  description = "The name of the first RDS database"
  type        = string
  default     = "rds_instance1"
}

variable "db_name2" {
  description = "The name of the second RDS database"
  type        = string
  default     = "rds_instance2"
}

variable "db_username1" {
  description = "The username for the first RDS instance"
  type        = string
  default     = "admin1"
}

variable "db_password1" {
  description = "The password for the first RDS instance"
  type        = string
  sensitive   = true
}

variable "db_username2" {
  description = "The username for the second RDS instance"
  type        = string
  default     = "admin2"
}

variable "db_password2" {
  description = "The password for the second RDS instance"
  type        = string
  sensitive   = true
}
