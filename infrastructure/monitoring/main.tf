resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = var.prometheus_namespace
  }
}

resource "helm_release" "prometheus" {
  name       = "kube-prometheus-stack"
  namespace  = var.prometheus_namespace
  version    = var.prometheus_version
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [<<EOT
kubeControllerManager:
  enabled: false
kubeScheduler:
  enabled: false
alertmanager:
  alertmanagerSpec:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: eks.amazonaws.com/compute-type
                  operator: In
                  values:
                    - hybrid
prometheus:
  admissionWebhooks:
    deployment:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: eks.amazonaws.com/compute-type
                    operator: In
                    values:
                      - hybrid
    patch:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: eks.amazonaws.com/compute-type
                    operator: In
                    values:
                      - hybrid
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: eks.amazonaws.com/compute-type
                operator: In
                values:
                  - hybrid
  prometheusOperator:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: eks.amazonaws.com/compute-type
                  operator: In
                  values:
                    - hybrid
thanosRuler:
  thanosRulerSpec:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: eks.amazonaws.com/compute-type
                  operator: In
                  values:
                    - hybrid
EOT
  ]

  depends_on = [kubernetes_namespace.prometheus]
}
