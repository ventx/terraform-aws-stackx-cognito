variable "name" {
  description = "Base Name for all resources (preferably generated by terraform-null-label) - will also be part in the Cognito User Pool Amazon Domain"
  type        = string
  default     = "stackx-auth"
}

variable "tags" {
  description = "User specific Tags / Labels to attach to resources (will be merged with module tags)"
  type        = map(string)
  default     = {}
}

variable "static_unique_id" {
  description = "Static unique ID, defined in the root module once, to be suffixed to all resources for uniqueness (if you choose uuid / longer id, some resources will be cut of at max length - empty means disable and NOT add unique suffix)"
  type        = string
  default     = ""
}

variable "domain_allow_list" {
  description = "Domains to allow in pre-sign-up Lambda (e.g. `example.com` or `test123.de, example.com, xyz.de`)"
  type        = string
  default     = "stackx.cloud"
}

variable "users" {
  description = "Dynamic list of Cognito Users to create (email)"
  type = map(
    object({
      email = string
    })
  )
}

variable "callback_urls" {
  description = "List of Callback URLs to use in User Pool Client (e.g. `https://dex.example.com/dex/callback`)"
  type        = list(string)
  default     = []
}


variable "user_groups" {
  description = "Dynamic list of Cognito User Pool Groups to create"
  type = map(
    object({
      name = string
    })
  )
}

variable "user_pool_clients" {
  description = "Dynamic list of Cognito User Pool Clients to create"
  type = map(
    object({
      name                                 = string
      callback_urls                        = list(string)
      allowed_oauth_flows_user_pool_client = bool
      allowed_oauth_flows                  = list(string)
      allowed_oauth_scopes                 = list(string)
      generate_secret                      = bool
      supported_identity_providers         = list(string)
    })
  )
}
