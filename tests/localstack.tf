//
// Provider configuration for Localstack
// If running against real cloud provider, please delete/disable this file
//
provider "aws" {

  access_key = "mock_access_key"
  secret_key = "mock_secret_key"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    cognitoidentity         = "http://localhost:4566"
    cognitoidentityprovider = "http://localhost:4566"
    cognitoidp              = "http://localhost:4566"
    iam                     = "http://localhost:4566"
    lambda                  = "http://localhost:4566"
    sts                     = "http://localhost:4566"
  }
}
