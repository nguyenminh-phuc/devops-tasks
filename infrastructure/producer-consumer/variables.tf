variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "s3_tf_bucket" {
  description = "Name of the S3 bucket for Terraform states"
  type        = string
  default     = "agileops-tf-states"
}

variable "s3_monitoring_key" {
  description = "S3 key for the Prometheus Terraform state file"
  type        = string
  default     = "monitoring/terraform.tfstate"
}

variable "s3_vpn_key" {
  description = "S3 key for the S2S VPN Terraform state file"
  type        = string
  default     = "s2s-vpn/terraform.tfstate"
}

variable "s3_access_key_id" {
  description = "AWS access key ID for processed-data consumers to interact with S3"
  type        = string
  sensitive   = true
}

variable "s3_secret_access_key" {
  description = "AWS secret access key for processed-data consumers to interact with S3"
  type        = string
  sensitive   = true
}

variable "s3_parquet_bucket" {
  description = "Name of the S3 bucket for processed-data consumers to upload Parquet files"
  type        = string
}

variable "kafka_namespace" {
  description = "Namespace for Kafka services"
  type        = string
  default     = "kafka"
}

variable "kafka_version" {
  description = "Version of Kafka to install"
  type        = string
  default     = "31.1.1"
}

variable "topic_raw_partitions" {
  description = "Number of partitions for the raw-data topic"
  type        = number
  default     = 3
}

variable "topic_processed_partitions" {
  description = "Number of partitions for the processed-data topic"
  type        = number
  default     = 3
}

variable "app_namespace" {
  description = "Namespace for consumer and producer services"
  type        = string
  default     = "agileops"
}

variable "app_service_monitor_enabled" {
  description = "Enable ServiceMonitor for the applications"
  type        = bool
  default     = true
}

variable "app_otlp_exporter_enabled" {
  description = "Enable OTLP exporters for the applications"
  type        = bool
  default     = false
}

variable "app_otlp_exporter_endpoint" {
  description = "OTLP endpoint for application export"
  type        = string
  default     = ""
}

variable "app_repository" {
  description = "Repository hosting the application Helm charts"
  type        = string
  default     = "registry-1.docker.io/phucapps"
}

variable "app_raw_producer_chart" {
  description = "Name of the raw-kproducer Helm chart"
  type        = string
  default     = "raw-kproducer"
}

variable "app_raw_producer_version" {
  description = "Version of the raw-kproducer Helm chart"
  type        = string
  default     = "1.0.0"
}

variable "app_raw_producer_replicas" {
  description = "Replica count for the raw-kproducer deployment"
  type        = string
  default     = 3
}

variable "app_raw_producer_sleep_ms" {
  description = "Sleep time in milliseconds between each raw-data production event"
  type        = number
  default     = 1000
}

variable "app_raw_consumer_chart" {
  description = "Name of the raw-kconsumer Helm chart"
  type        = string
  default     = "raw-kconsumer"
}

variable "app_raw_consumer_version" {
  description = "Version of the raw-kconsumer Helm chart"
  type        = string
  default     = "1.0.0"
}

variable "app_raw_consumer_postgres_password" {
  description = "Password for the raw-kconsumer's Postgres database"
  type        = string
  sensitive   = true
}

variable "app_processed_consumer_chart" {
  description = "Name of the processed-kconsumer Helm chart"
  type        = string
  default     = "processed-kconsumer"
}

variable "app_processed_consumer_version" {
  description = "Version of the processed-kconsumer Helm chart"
  type        = string
  default     = "1.0.0"
}

variable "app_processed_consumer_postgres_password" {
  description = "Password for the processed-kconsumer's Postgres database"
  type        = string
  sensitive   = true
}
