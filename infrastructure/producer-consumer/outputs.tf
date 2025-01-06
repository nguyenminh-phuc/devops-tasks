output "s3_parquet_arn" {
  description = "ARN of the S3 Parquet bucket"
  value       = aws_s3_bucket.s3_parquet.arn
}

output "kafka_namespace" {
  description = "Namespace for Kafka services"
  value       = var.kafka_namespace
}

output "kafka_version" {
  description = "Installed Kafka version"
  value       = var.kafka_version
}

output "raw_producer_version" {
  description = "Installed raw-kproducer version"
  value       = var.app_raw_producer_version
}

output "raw_consumer_version" {
  description = "Installed raw-kconsumer version"
  value       = var.app_raw_consumer_version
}

output "processed_consumer_version" {
  description = "Installed processed-kconsumer version"
  value       = var.app_processed_consumer_version
}

output "raw_consumer_postgres_password" {
  description = "Password for the raw-kconsumer's Postgres database"
  value       = var.app_raw_consumer_postgres_password
  sensitive   = true
}

output "processed_consumer_postgres_password" {
  description = "Password for the processed-kconsumer's Postgres database"
  value       = var.app_processed_consumer_postgres_password
  sensitive   = true
}
