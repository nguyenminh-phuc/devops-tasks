resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = var.longhorn_namespace
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  namespace  = var.longhorn_namespace
  version    = var.longhorn_version
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"

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

  depends_on = [kubernetes_namespace.longhorn]
}
