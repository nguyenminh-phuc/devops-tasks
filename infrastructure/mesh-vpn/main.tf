locals {
  vpc_name = "eks"

  netmaker_name          = "netmaker"
  netmaker_version       = "v0.26.0"
  netmaker_instance_type = "t3.micro"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17.0"

  name = local.vpc_name
  cidr = var.vpc_subnet

  azs             = var.availability_zones
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dhcp_options              = true
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  default_security_group_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  default_security_group_ingress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # https://repost.aws/knowledge-center/eks-vpc-subnet-discovery
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "netmaker" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.7"

  name = local.netmaker_name

  ami           = var.netmaker_ami
  instance_type = local.netmaker_instance_type

  subnet_id  = module.vpc.public_subnets[0]
  create_eip = true

  key_name               = var.netmaker_key
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  source_dest_check      = false

  user_data = <<-EOT
    #!/bin/bash
    wget -qO /root/nm-quick.sh https://raw.githubusercontent.com/gravitl/netmaker/${local.netmaker_version}/scripts/nm-quick.sh
    chmod +x /root/nm-quick.sh
  EOT

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 10
    }
  ]
}

resource "aws_route" "private_subnets_to_node_subnet" {
  count = length(module.vpc.private_route_table_ids)

  route_table_id         = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.node_subnet
  network_interface_id   = module.netmaker.primary_network_interface_id
}

resource "aws_route" "public_subnets_to_node_subnet" {
  count = length(module.vpc.public_route_table_ids)

  route_table_id         = module.vpc.public_route_table_ids[count.index]
  destination_cidr_block = var.node_subnet
  network_interface_id   = module.netmaker.primary_network_interface_id
}

resource "aws_route" "private_subnets_to_pod_subnet" {
  count = length(module.vpc.private_route_table_ids)

  route_table_id         = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.pod_subnet
  network_interface_id   = module.netmaker.primary_network_interface_id
}

resource "aws_route" "public_subnets_to_pod_subnet" {
  count = length(module.vpc.public_route_table_ids)

  route_table_id         = module.vpc.public_route_table_ids[count.index]
  destination_cidr_block = var.pod_subnet
  network_interface_id   = module.netmaker.primary_network_interface_id
}
