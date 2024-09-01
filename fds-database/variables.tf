variable "db_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "db_name" {
  description = "The database name"
  type        = string
}

variable "db_username" {
    description = "username of the database"
    type        = string
}

variable "db_password" {
  description = "Database Password"
  type        = string
}

variable "allowed_ip" {
  description = "The IP address allowed to access the RDS instance"
  type        = string
}
