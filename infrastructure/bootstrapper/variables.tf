variable "region" {
  description = "AWS region"
  type        = string
}

variable "s3_tf" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "dynamodb_tf" {
  description = "Name of the DynamoDB table"
  type        = string
}
