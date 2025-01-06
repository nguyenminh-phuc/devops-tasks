output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "s3_endpoint" {
  description = "The DNS name of the S3 interface endpoint"
  value       = "https://bucket${trimprefix(module.endpoints.endpoints["s3"]["dns_entry"][0]["dns_name"], "*")}"
}

output "vpc_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "vpn_connection_id" {
  description = "The ID of the VPN connection"
  value       = module.vpn_gateway.vpn_connection_id
}

output "vpn_connection_tunnel1_address" {
  description = "The public IP address of the first VPN tunnel"
  value       = module.vpn_gateway.vpn_connection_tunnel1_address
}

output "vpn_connection_tunnel2_address" {
  description = "The public IP address of the second VPN tunnel"
  value       = module.vpn_gateway.vpn_connection_tunnel2_address
}

output "tunnel1_preshared_key" {
  description = "The preshared key of the first VPN tunnel"
  value       = module.vpn_gateway.tunnel1_preshared_key
  sensitive   = true
}

output "tunnel2_preshared_key" {
  description = "The preshared key of the second VPN tunnel"
  value       = module.vpn_gateway.tunnel2_preshared_key
  sensitive   = true
}
