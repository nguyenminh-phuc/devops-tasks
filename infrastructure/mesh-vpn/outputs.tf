output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "vpc_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "netmaker_ip" {
  description = "Public IP address of the Netmaker instance"
  value       = module.netmaker.public_ip
}

output "node_subnet" {
  description = "CIDR block for the node subnet"
  value       = var.node_subnet
}

output "pod_subnet" {
  description = "CIDR block for the pod subnet"
  value       = var.pod_subnet
}
