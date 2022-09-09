output "arn" {
  value = aws_cognito_user_pool.pool.*.arn
}

output "endpoint" {
  value = aws_cognito_user_pool.pool.endpoint
}

output "id" {
  value = aws_cognito_user_pool.pool.id
}

output "name" {
  value = aws_cognito_user_pool.pool.name
}

output "tags" {
  value = aws_cognito_user_pool.pool.tags
}

output "client_id" {
  value = {
    for k, v in aws_cognito_user_pool_client.client : k => v.id
  }
}

output "client_secret" {
  value = {
    for k, v in aws_cognito_user_pool_client.client : k => v.client_secret
  }
  sensitive = true
}

output "callback_urls" {
  value = {
    for k, v in aws_cognito_user_pool_client.client : k => v.callback_urls
  }
}

output "lambda_pre_sign_up_arn" {
  value = aws_lambda_function.pre_sign_up.arn
}
