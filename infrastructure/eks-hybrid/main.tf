data "terraform_remote_state" "mesh_vpn" {
  backend = "s3"

  config = {
    bucket = var.s3_tf_bucket
    key    = var.s3_mesh_vpn_key
    region = var.region
  }
}

locals {
  eks_name        = "eks-hybrid"
  eks_version     = "1.31"
  eks_vpc_id      = data.terraform_remote_state.mesh_vpn.outputs.vpc_id
  eks_subnet_ids  = data.terraform_remote_state.mesh_vpn.outputs.vpc_public_subnets
  eks_node_subnet = data.terraform_remote_state.mesh_vpn.outputs.node_subnet
  eks_pod_subnet  = data.terraform_remote_state.mesh_vpn.outputs.pod_subnet

  ssm_registration_limit = 10
}

module "eks_hybrid_role" {
  source  = "terraform-aws-modules/eks/aws//modules/hybrid-node-role"
  version = "~> 20.31"
}

# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v20.31.6/examples/eks-auto-mode/main.tf
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v20.31.6/examples/eks-hybrid-nodes/main.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = local.eks_name
  cluster_version = local.eks_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  # Auto Mode
  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  cluster_security_group_additional_rules = {
    hybrid-all = {
      cidr_blocks = ["0.0.0.0/0", local.eks_node_subnet, local.eks_pod_subnet]
      description = "Allow all traffic from remote node/pod network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
  }

  access_entries = {
    hybrid-node-role = {
      principal_arn = module.eks_hybrid_role.arn
      type          = "HYBRID_LINUX"
    }
  }

  vpc_id     = local.eks_vpc_id
  subnet_ids = local.eks_subnet_ids

  cluster_remote_network_config = {
    remote_node_networks = {
      cidrs = [local.eks_node_subnet]
    }
    remote_pod_networks = {
      cidrs = [local.eks_pod_subnet]
    }
  }
}

resource "aws_ssm_activation" "ssm" {
  iam_role           = module.eks_hybrid_role.name
  registration_limit = local.ssm_registration_limit
}

# https://github.com/aws/eks-hybrid/tree/v1.0.0?tab=readme-ov-file#configuration
resource "local_file" "eks_config" {
  filename = "nodeConfig.yaml"
  content = templatefile("nodeConfig.yaml.tftpl", {
    cluster_name        = module.eks.cluster_name
    cluster_region      = var.region
    ssm_activation_code = aws_ssm_activation.ssm.activation_code
    ssm_activation_id   = aws_ssm_activation.ssm.id
  })
}
