module "ingress_nginx_namespace" {
  source = "./modules/namespace"
  name = "ingress"
  labels = {
    name = "ingress"
  }
}

module "ingress_nginx_setup" {
  source = "./modules/ingress-nginx"
  namespace = module.ingress_nginx_namespace.name
}