output "prometheus_namespace" {
  description = "Namespace for Prometheus services"
  value       = var.prometheus_version
}

output "prometheus_version" {
  description = "Installed Prometheus version"
  value       = var.prometheus_version
}
