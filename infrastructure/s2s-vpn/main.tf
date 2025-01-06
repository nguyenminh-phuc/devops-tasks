locals {
  vpc_name              = "eks-vpc"
  customer_gateway_asn  = 65000
  customer_gateway_name = "eks-cgw"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17.0"

  name = local.vpc_name
  cidr = var.vpc_subnet

  azs             = var.availability_zones
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = false

  enable_vpn_gateway = true

  # https://repost.aws/knowledge-center/eks-vpc-subnet-discovery
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# https://github.com/terraform-aws-modules/terraform-aws-vpn-gateway/tree/v4.0.0/examples/complete-vpn-gateway-with-static-routes
module "vpn_gateway" {
  source  = "terraform-aws-modules/vpn-gateway/aws"
  version = "~> 4.0.0"

  vpn_connection_static_routes_only         = true
  vpn_connection_static_routes_destinations = var.customer_subnets

  vpn_gateway_id      = module.vpc.vgw_id
  customer_gateway_id = aws_customer_gateway.customer_gateway.id

  vpc_id                       = module.vpc.vpc_id
  vpc_subnet_route_table_ids   = module.vpc.private_route_table_ids
  vpc_subnet_route_table_count = length(var.vpc_private_subnets)
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = local.customer_gateway_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name = local.customer_gateway_name
  }
}

# https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/v5.17.0/modules/vpc-endpoints/main.tf
module "endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.17.0"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name_prefix = "eks-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC and on-prem subnets"
      cidr_blocks = concat([module.vpc.vpc_cidr_block], var.customer_subnets)
    }
  }

  endpoints = {
    s3 = {
      service             = "s3",
      subnet_ids          = module.vpc.private_subnets
      ip_address_type     = "ipv4"
      private_dns_enabled = true

      # https://registry.terraform.io/providers/hashicorp/aws/5.82.2/docs/resources/vpc_endpoint#dns_options
      dns_options = {
        dns_record_ip_type                             = "ipv4"
        private_dns_only_for_inbound_resolver_endpoint = true
      }
    }
  }
}
