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

variable "s3_producer_consumer_key" {
  description = "S3 key for the producer-consumer Terraform state file"
  type        = string
  default     = "producer-consumer/terraform.tfstate"
}

variable "grafana_url" {
  description = "URL of the Grafana server"
  type        = string
}

variable "grafana_auth" {
  description = "API token to access Grafana server"
  type        = string
}

variable "kafka_exporter_version" {
  description = "Version of Kafka exporter to install"
  type        = string
  default     = "2.11.0"
}
