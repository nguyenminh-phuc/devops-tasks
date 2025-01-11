variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "longhorn_namespace" {
  description = "Namespace for Longhorn services"
  type        = string
}

variable "longhorn_version" {
  description = "Version of Longhorn to install"
  type        = string
}
