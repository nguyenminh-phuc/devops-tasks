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

variable "s3_s2s_vpn_key" {
  description = "S3 key for the S2S VPN Terraform state file"
  type        = string
  default     = "s2s-vpn/terraform.tfstate"
}

variable "customer_subnets" {
  description = "CIDR blocks for the customer's private network"
  type        = list(string)
  default     = ["10.80.0.0/16", "10.85.0.0/16"]
}

variable "customer_node_subnet" {
  description = "CIDR block for the customer's node network"
  type        = string
  default     = "10.80.0.0/16"
}

variable "customer_pod_subnet" {
  description = "CIDR block for the customer's pod network"
  type        = string
  default     = "10.85.0.0/16"
}
