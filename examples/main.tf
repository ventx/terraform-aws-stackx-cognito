module "stackx-cognito" {
  source = "../"

  static_unique_id = "f2f6c971-6a3c-4d6e-9dca-7a3ba454d64d" # just random uuid generated for testing cut offs etc

  tags = {
    examples = "example"
  }
  user_groups = {
    test = {
      name = "test"
    }
  }
  user_pool_clients = {
    test = {
      name                                 = "test"
      callback_urls                        = ["https://stackx.cloud"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_flows                  = ["code"]
      allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
      generate_secret                      = true
      supported_identity_providers         = ["COGNITO"]
    }
  }
  users = {
    test1 = {
      email = "test1@stackx.cloud"
    }
    test2 = {
      email = "test2@stackx.cloud"
    }
  }
}
