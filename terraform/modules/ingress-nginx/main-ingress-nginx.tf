resource "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = var.namespace

    annotations = {
      "prometheus.io/port" = "10254"

      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = "443"
    }

    selector = {
      name = "nginx-ingress-controller"

      phase = "prod"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "nginx_ingress_controller" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = var.namespace
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        name = "nginx-ingress-controller"

        phase = "prod"
      }
    }

    template {
      metadata {
        labels = {
          name = "nginx-ingress-controller"

          phase = "prod"
        }

        annotations = {
          "seccomp.security.alpha.kubernetes.io/pod" = "docker/default"
        }
      }

      spec {
        container {
          name  = "nginx-ingress-controller"
          image = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1"
          args  = ["/nginx-ingress-controller", "--ingress-class=public"]

          port {
            name           = "http"
            host_port      = 80
            container_port = 80
          }

          port {
            name           = "https"
            host_port      = 443
            container_port = 443
          }

          port {
            name           = "health"
            host_port      = 10254
            container_port = 10254
          }

          env {
            name = "POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          liveness_probe {
            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            timeout_seconds   = 5
            period_seconds    = 10
            success_threshold = 1
            failure_threshold = 3
          }

          security_context {
            run_as_user = 33
            capabilities {
              add = ["NET_BIND_SERVICE"]
              drop = ["ALL"]
            }
          }
        }

        restart_policy                   = "Always"
        termination_grace_period_seconds = 60
      }
    }

    strategy {
      rolling_update {
        max_unavailable = "1"
      }
    }
  }
}
