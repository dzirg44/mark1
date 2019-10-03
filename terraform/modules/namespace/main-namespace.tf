resource "kubernetes_namespace" "main" {
  metadata {
    name = var.name
    labels = var.labels
  }
}

