#Update URL when team decides dns name


# Name of the Cognito User Pool
variable "cognito_user_pool_name" {
  description = "The name of the Cognito User Pool"
  type        = string
  default     = "project-user-pool"
}

# Minimum length for user passwords
variable "password_minimum_length" {
  description = "Minimum length of the user password"
  type        = number
  default     = 8
}

# MFA configuration (OPTIONAL, REQUIRED, or OFF)
variable "mfa_configuration" {
  description = "MFA configuration for the user pool"
  type        = string
  default     = "OPTIONAL"
}

# Auto-verified attributes
variable "auto_verified_attributes" {
  description = "Attributes that will be auto-verified"
  type        = list(string)
  default     = ["email"]
}

# Admin create user configuration
variable "allow_admin_create_user_only" {
  description = "Allow only admin to create users"
  type        = bool
  default     = true
}

# Name of the Cognito User Pool Client
variable "cognito_user_pool_client_name" {
  description = "The name of the Cognito User Pool Client"
  type        = string
  default     = "project-user-pool-client"
}

# Callback URLs for the User Pool Client
variable "callback_urls" {
  description = "The callback URLs for the Cognito User Pool Client"
  type        = list(string)
  default     = ["https://devorderz.com/callback"]
}

# OAuth allowed flows
variable "allowed_oauth_flows" {
  description = "Allowed OAuth flows for the Cognito User Pool Client"
  type        = list(string)
  default     = ["code"]
}

# OAuth allowed scopes
variable "allowed_oauth_scopes" {
  description = "Allowed OAuth scopes for the Cognito User Pool Client"
  type        = list(string)
  default     = ["email", "openid", "profile"]
}

# Whether to generate a client secret
variable "generate_secret" {
  description = "Whether to generate a client secret"
  type        = bool
  default     = false
}
