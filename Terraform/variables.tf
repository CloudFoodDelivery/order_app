# RDS
variable "db_identifier" {
  description = "Specific name for the db in the console"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_username" {
  description = "The database admin username"
  type        = string
}

variable "db_password" {
  description = "The database admin password"
  type        = string
}

variable "allowed_ip" {
  description = "IP range allowed to access RDS"
  type        = string
}

# S3
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

# ACM 
variable "acm_arn" {
  description = "Providing arn for the certificate"
  type        = string
}

# Route53 

variable "hosted_zone_id"  {
  description = "Providing the hosted zone id"

}