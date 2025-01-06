data "terraform_remote_state" "monitoring" {
  backend = "s3"

  config = {
    bucket = var.s3_tf_bucket
    key    = var.s3_monitoring_key
    region = var.region
  }
}

data "terraform_remote_state" "s2s-vpn" {
  backend = "s3"

  config = {
    bucket = var.s3_tf_bucket
    key    = var.s3_vpn_key
    region = var.region
  }
}

locals {
  storage_class        = "longhorn"
  prometheus_namespace = data.terraform_remote_state.monitoring.outputs.prometheus_namespace

  kafka_port     = 9092 # Default port
  kafka_endpoint = "kafka.${var.kafka_namespace}.svc:${local.kafka_port}"

  topic_raw       = "raw-data"
  topic_processed = "processed-data"

  group_raw       = "raw-group-0"
  group_processed = "processed-group-0"

  postgres_raw       = "raw-kconsumer-postgresql"
  postgres_processed = "processed-kconsumer-postgresql"

  s3_endpoint = data.terraform_remote_state.s2s-vpn.outputs.s3_endpoint
}

resource "kubernetes_namespace" "kafka" {
  metadata {
    name = var.kafka_namespace
  }
}

resource "helm_release" "kafka" {
  name       = "kafka"
  namespace  = var.kafka_namespace
  version    = var.kafka_version
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"

  values = [<<EOT
listeners:
  client:
    protocol: PLAINTEXT
  controller:
    protocol: PLAINTEXT
  interbroker:
    protocol: PLAINTEXT
  external:
    protocol: PLAINTEXT
controller:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: eks.amazonaws.com/compute-type
                operator: In
                values:
                  - hybrid
  resourcesPreset: none
  persistence:
    storageClass: ${local.storage_class}
provisioning:
  enabled: true
  nodeSelector:
    eks.amazonaws.com/compute-type: hybrid
  resourcesPreset: none
  topics:
    - name: ${local.topic_raw}
      partitions: ${var.topic_raw_partitions}
    - name: ${local.topic_processed}
      partitions: ${var.topic_processed_partitions}
metrics:
  jmx:
    enabled: true
    resourcesPreset: none
  serviceMonitor:
    enabled: true
    namespace: ${local.prometheus_namespace}
EOT
  ]

  depends_on = [kubernetes_namespace.kafka]
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_namespace
  }
}

resource "helm_release" "raw_producer" {
  name       = "raw-kproducer"
  namespace  = var.app_namespace
  version    = var.app_raw_producer_version
  repository = var.app_repository
  chart      = var.app_raw_producer_chart

  values = [<<EOT
replicaCount: ${var.app_raw_producer_replicas}
serviceMonitor:
  enabled: ${var.app_service_monitor_enabled}
  namespace: ${local.prometheus_namespace}
otlpExporter:
  enabled: ${var.app_otlp_exporter_enabled}
  endpoint: ${var.app_otlp_exporter_endpoint}
kafka:
  endpoint: ${local.kafka_endpoint}
  rawTopic: ${local.topic_raw}
  sleepTimeInMilliseconds: ${var.app_raw_producer_sleep_ms}
EOT
  ]

  depends_on = [kubernetes_namespace.app, helm_release.kafka]
}


resource "kubernetes_secret" "raw_consumer_postgres" {
  metadata {
    name      = local.postgres_raw
    namespace = var.app_namespace
  }

  data = {
    "password"          = var.app_raw_consumer_postgres_password
    "postgres-password" = var.app_raw_consumer_postgres_password
  }
}

resource "helm_release" "raw_consumer" {
  count = var.topic_raw_partitions

  name       = "raw-kconsumer-${count.index}"
  namespace  = var.app_namespace
  version    = var.app_raw_consumer_version
  repository = var.app_repository
  chart      = var.app_raw_consumer_chart

  values = [<<EOT
serviceMonitor:
  enabled: ${var.app_service_monitor_enabled}
  namespace: ${local.prometheus_namespace}
otlpExporter:
  enabled: ${var.app_otlp_exporter_enabled}
  endpoint: ${var.app_otlp_exporter_endpoint}
kafka:
  endpoint: ${local.kafka_endpoint}
  processedTopic: ${local.topic_processed}
  rawTopic: ${local.topic_raw}
  rawGroup: ${local.group_raw}
postgresql:
  auth:
    existingSecret: ${local.postgres_raw}
    persistence:
      storageClass: ${local.storage_class}
EOT
  ]

  depends_on = [kubernetes_namespace.app, kubernetes_secret.raw_consumer_postgres, helm_release.kafka]
}

resource "aws_s3_bucket" "s3_parquet" {
  bucket = var.s3_parquet_bucket
}

resource "aws_s3_bucket_versioning" "s3_parquet_versioning" {
  bucket = aws_s3_bucket.s3_parquet.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_parquet_encryption" {
  bucket = aws_s3_bucket.s3_parquet.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "kubernetes_secret" "processed_consumer_postgres" {
  metadata {
    name      = local.postgres_processed
    namespace = var.app_namespace
  }

  data = {
    "password"          = var.app_processed_consumer_postgres_password
    "postgres-password" = var.app_processed_consumer_postgres_password
  }
}

resource "helm_release" "processed_consumer" {
  count = var.topic_processed_partitions

  name       = "processed-kconsumer-${count.index}"
  namespace  = var.app_namespace
  version    = var.app_processed_consumer_version
  repository = var.app_repository
  chart      = var.app_processed_consumer_chart

  values = [<<EOT
serviceMonitor:
  enabled: ${var.app_service_monitor_enabled}
  namespace: ${local.prometheus_namespace}
otlpExporter:
  enabled: ${var.app_otlp_exporter_enabled}
  endpoint: ${var.app_otlp_exporter_endpoint}
s3:
  accessKeyId: ${var.s3_access_key_id}
  secretAccessKey: ${var.s3_secret_access_key}
  region: ${var.region}
  endpoint: ${local.s3_endpoint}
  bucket: ${var.s3_parquet_bucket}
kafka:
  endpoint: ${local.kafka_endpoint}
  processedTopic: ${local.topic_processed}
  processedGroup: ${local.group_processed}
postgresql:
  auth:
    existingSecret: ${local.postgres_processed}
    persistence:
      storageClass: ${local.storage_class}
EOT
  ]

  depends_on = [aws_s3_bucket.s3_parquet, kubernetes_namespace.app, kubernetes_secret.processed_consumer_postgres, helm_release.kafka]
}
