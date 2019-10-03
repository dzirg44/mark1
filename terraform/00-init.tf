#terraform {
#  backend "s3" {}
#}
terraform {
  backend "local" {}
}

provider "kubernetes" {
  config_context_auth_info = "kubernetes-alpha-user"
  config_context_cluster   = "kubernetes-alpha-cluster"
}



