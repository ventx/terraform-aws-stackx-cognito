variable "tags" {
  default = {
    "owner"     = "terraform-aws-terratest",
    "managedby" = "terratest",
    "project"   = "stackx",
    "workspace" = "terratest"
  }
}
