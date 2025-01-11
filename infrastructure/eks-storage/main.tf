resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = var.longhorn_namespace
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  version    = var.longhorn_version
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  namespace  = kubernetes_namespace.longhorn.metadata[0].name

  values = [<<EOT
longhornManager:
  nodeSelector:
    eks.amazonaws.com/compute-type: hybrid
longhornDriver:
  nodeSelector:
    eks.amazonaws.com/compute-type: hybrid
longhornUI:
  nodeSelector:
    eks.amazonaws.com/compute-type: hybrid
EOT
  ]
}
