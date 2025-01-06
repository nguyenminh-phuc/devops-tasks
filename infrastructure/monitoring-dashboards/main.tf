data "terraform_remote_state" "producer_consumer" {
  backend = "s3"

  config = {
    bucket = var.s3_tf_bucket
    key    = var.s3_producer_consumer_key
    region = var.region
  }
}

locals {
  kafka_namespace = data.terraform_remote_state.producer_consumer.outputs.kafka_namespace
}

resource "grafana_folder" "solution1" {
  title = "Solution1"
}

resource "grafana_folder" "solution2" {
  title = "Solution2"
}

resource "grafana_folder" "kafka" {
  title = "Kafka"
}

# https://github.com/RiskyAdventure/Troubleshooting-Dashboards
resource "grafana_dashboard" "troubleshooting_dashboards" {
  for_each = fileset("${path.module}/Troubleshooting-Dashboards", "*.json")

  config_json = file("Troubleshooting-Dashboards/${each.key}")
  folder      = grafana_folder.solution1.id
}

# https://grafana.com/grafana/dashboards/21073-monitoring-golden-signals/
resource "grafana_dashboard" "monitoring_golden_signals" {
  config_json = file("monitoring-golden-signals/21073_rev1.json")
  folder      = grafana_folder.solution2.id
}

# https://grafana.com/grafana/dashboards/7589-kafka-exporter-overview/
resource "grafana_dashboard" "kafka_exporter" {
  config_json = file("kafka_exporter/7589_rev5.json")
  folder      = grafana_folder.kafka.id

  depends_on = [helm_release.kafka_exporter]
}

resource "helm_release" "kafka_exporter" {
  name       = "kafka_exporter"
  namespace  = local.kafka_namespace
  version    = var.kafka_exporter_version
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-kafka-exporter"

  values = [<<EOT
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
}
