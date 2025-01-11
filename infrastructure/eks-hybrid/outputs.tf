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
  value       = local.eks_pod_subnet
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

output "eks_config" {
  description = "Full path to the generated nodeConfig.yaml file"
  value       = abspath(local_file.eks_config.filename)
}

data "aws_network_interfaces" "eks" {
  filter {
    # https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeNetworkInterfaces.html
    name   = "group-id"
    values = [module.eks.cluster_security_group_id]
  }

  depends_on = [module.eks.time_sleep]
}

data "aws_network_interface" "eks" {
  count = 2
  id    = data.aws_network_interfaces.eks.ids[count.index]
}

output "eks_private_ips" {
  description = "EKS private endpoints"
  value = flatten([
    for interface in data.aws_network_interface.eks : interface.private_ips
  ])
}
