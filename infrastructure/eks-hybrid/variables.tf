variable "region" {
  description = "AWS region"
  type        = string
}

variable "s3_tf_bucket" {
  description = "Name of the S3 bucket for Terraform states"
  type        = string
}

variable "s3_mesh_vpn_key" {
  description = "S3 key for the Mesh VPN Terraform state file"
  type        = string
}
