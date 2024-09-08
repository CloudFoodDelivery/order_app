# Output the Cognito User Pool ID
output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.project_user_pool.id
}

# Output the Cognito User Pool ARN
output "cognito_user_pool_arn" {
  description = "The ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.project_user_pool.arn
}

# Output the Cognito User Pool Client ID

output "cognito_user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.project_user_pool_client.id
}
