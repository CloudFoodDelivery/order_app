# Cognito User pool
resource "aws_cognito_user_pool" "project_user_pool" {
  name = "project-user-pool"

  password_policy {
    minimum_length = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers = true
    require_symbols = false
  }

  mfa_configuration = "OPTIONAL"

  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  #Cognito User Pool Client
  resource "aws_cognito_user_pool_client" "project_user_pool_client" {
    name = "project-user-pool-client"
    user_pool_id = aws_cognito_user_pool.project_user_pool.id

    generate_secret = false

    callback_urls = ["https://devorderz.com/callback"]

    allowed_oauth_flows = ["code"]

    allowed_oauth_scoped = ["email","openid","profile"]

    allowed_oauth_flows_user_pool_client = true
  }
}
