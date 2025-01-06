data "terraform_remote_state" "eks_hybrid" {
  backend = "s3"

  config = {
    bucket = var.s3_tf_bucket
    key    = var.s3_eks_hybrid_key
    region = var.region
  }
}

locals {
  calico_subnet = data.terraform_remote_state.eks_hybrid.outputs.eks_pod_subnet

  # By default, Calico uses an IPAM block size of 64 addresses – /26 for IPv4
  # https://docs.tigera.io/calico/3.29/networking/ipam/change-block-size
  calico_block_size = 26
}

resource "helm_release" "calico" {
  chart      = "tigera-operator"
  name       = "calico"
  version    = var.calico_version
  repository = "https://docs.tigera.io/calico/charts"
  namespace  = "kube-system"

  values = [templatefile("calico.yaml.tftpl", {
    calico_subnet     = local.calico_subnet
    calico_block_size = local.calico_block_size
  })]
}

# https://docs.aws.amazon.com/eks/latest/userguide/auto-elb-example.html#_step_4_configure_load_balancing
resource "kubernetes_ingress_class" "alb" {
  metadata {
    name = "alb"
    labels = {
      "app.kubernetes.io/name" = "LoadBalancerController"
    }
  }

  spec {
    controller = "eks.amazonaws.com/alb"
  }

  depends_on = [helm_release.calico]
}
