output "eks_name" {
  description = "Name of the EKS cluster"
  value       = local.eks_name
}

output "eks_version" {
  description = "Version of the EKS cluster"
  value       = local.eks_version
}

output "eks_pod_subnet" {
  description = "CIDR block for the pod network"
  value       = var.customer_pod_subnet
}

output "ssm_activation_id" {
  description = "Activation ID"
  value       = aws_ssm_activation.ssm.id
  sensitive   = true
}

output "ssm_activation_code" {
  description = "Activation code"
  value       = aws_ssm_activation.ssm.activation_code
  sensitive   = true
}

output "hybrid_config" {
  description = "Full path to the generated nodeConfig.yaml file"
  value       = abspath(local_file.hybrid_config.filename)
}
