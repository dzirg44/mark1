variable "name" {
  description = "Kubernetes: name for the namespace"
}


variable "labels" {
  description = "Kubernetes: labels for the namespace (map)"
  type = "map"
}