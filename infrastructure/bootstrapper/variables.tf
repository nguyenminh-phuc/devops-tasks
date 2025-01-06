variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "s3_tf" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "agileops-tf-states"
}

variable "dynamodb_tf" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "tf-locks"
}
