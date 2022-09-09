# --------------------------------------------------------------------------
# Locals - Tagging
# --------------------------------------------------------------------------
locals {
  tags = merge(
    var.tags,
    {
      "Module" = "terraform-aws-stackx-cognito"
      "Github" = "https://github.com/ventx/terraform-aws-stackx-cognito"
    }
  )
}


# --------------------------------------------------------------------------
# Cognito - Identity Pool
# --------------------------------------------------------------------------
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name = substr(lower("${var.name}${var.static_unique_id != "" ? "-" : ""}${var.static_unique_id != "" ? var.static_unique_id : ""}"), 0, 63)

  allow_unauthenticated_identities = false

  dynamic "cognito_identity_providers" {
    for_each = var.user_pool_clients
    content {
      client_id               = aws_cognito_user_pool_client.client[cognito_identity_providers.key].id
      provider_name           = aws_cognito_user_pool.pool.endpoint
      server_side_token_check = false
    }
  }

  tags = local.tags
}

# --------------------------------------------------------------------------
# Cognito - User Pool
# --------------------------------------------------------------------------
resource "aws_cognito_user_pool" "pool" {
  name = substr(lower("${var.name}${var.static_unique_id != "" ? "-" : ""}${var.static_unique_id != "" ? var.static_unique_id : ""}"), 0, 63)

  username_attributes = ["email"]

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
    invite_message_template {
      email_message = <<EOF
Hi,
<p>
A new account for <strong>${var.name}</strong> has been created for you.
</p>
<p></p>
<p>Username: {username}</p>
<p>Temporary password: {####}</p>
<p></p>
<p>Please login and change your password.</p>
<p>Have a nice day :)</p>
EOF
      email_subject = "Sign up for stackX"
      sms_message   = "Your username is {username}. Sign up at {####} "
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  lambda_config {
    pre_sign_up = aws_lambda_function.pre_sign_up.arn
  }

  password_policy {
    minimum_length                   = 18
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = false
    require_symbols                  = false
    temporary_password_validity_days = 2
  }

  username_configuration {
    case_sensitive = true
  }

  tags = local.tags
}


# --------------------------------------------------------------------------
# Cognito - User Pool Domain (Amazon Cognito domain)
# --------------------------------------------------------------------------
resource "aws_cognito_user_pool_domain" "main" {
  domain       = replace(substr(lower(trimspace((replace(var.name, "aws", "swa")))), 0, 63), "_", "-")
  user_pool_id = aws_cognito_user_pool.pool.id
}

# --------------------------------------------------------------------------
# Cognito - User Pool Client
# --------------------------------------------------------------------------
resource "aws_cognito_user_pool_client" "client" {
  for_each = var.user_pool_clients

  # TODO: set validations
  #Length Constraints: Minimum length of 1. Maximum length of 128.
  #Pattern: [\w\s+=,.@-]+
  name                                 = each.value.name
  user_pool_id                         = aws_cognito_user_pool.pool.id
  callback_urls                        = var.callback_urls
  allowed_oauth_flows_user_pool_client = each.value.allowed_oauth_flows_user_pool_client
  allowed_oauth_flows                  = each.value.allowed_oauth_flows
  allowed_oauth_scopes                 = each.value.allowed_oauth_scopes
  generate_secret                      = each.value.generate_secret
  supported_identity_providers         = each.value.supported_identity_providers
}


# --------------------------------------------------------------------------
# Cognito - User Group
# --------------------------------------------------------------------------
resource "aws_cognito_user_group" "users" {
  for_each = var.user_groups

  name         = "users"
  user_pool_id = aws_cognito_user_pool.pool.id
}

# --------------------------------------------------------------------------
# Cognito - Users
# --------------------------------------------------------------------------
resource "aws_cognito_user" "users" {
  for_each = var.users

  user_pool_id             = aws_cognito_user_pool.pool.id
  username                 = each.value.email
  desired_delivery_mediums = ["EMAIL"]

  attributes = {
    email          = each.value.email
    email_verified = true
  }

  validation_data = {
    email = each.value.email
  }

  depends_on = [aws_lambda_function.pre_sign_up, aws_lambda_permission.pre_sign_up]
}
