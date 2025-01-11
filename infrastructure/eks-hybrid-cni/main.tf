data "terraform_remote_state" "eks_hybrid" {
  backend = "s3"

  config = {
    bucket = var.s3_tf_bucket
    key    = var.s3_eks_hybrid_key
    region = var.region
  }
}

locals {
  eks_endpoint = data.terraform_remote_state.eks_hybrid.outputs.eks_private_ips[0]
}

resource "kubernetes_namespace" "calico" {
  metadata {
    name = var.calico_namespace
  }
}

resource "helm_release" "calico" {
  chart      = "tigera-operator"
  name       = "calico"
  version    = var.calico_version
  repository = "https://docs.tigera.io/calico/charts"
  namespace  = kubernetes_namespace.calico.metadata[0].name

  # https://docs.aws.amazon.com/eks/latest/userguide/hybrid-nodes-cni.html#_install_calico_on_hybrid_nodes
  values = [templatefile("calico.yaml.tftpl", {
    pod_subnets  = var.pod_subnets
    eks_endpoint = local.eks_endpoint
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
