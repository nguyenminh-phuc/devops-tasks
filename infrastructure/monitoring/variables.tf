variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "prometheus_namespace" {
  description = "Namespace for Prometheus services"
  type        = string
  default     = "monitoring"
}

variable "prometheus_version" {
  description = "Version of Prometheus to install"
  type        = string
  default     = "67.5.0"
}
