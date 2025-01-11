variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "s3_tf_bucket" {
  description = "Name of the S3 bucket for Terraform states"
  type        = string
}

variable "s3_eks_hybrid_key" {
  description = "S3 key for the EKS Hybrid Terraform state file"
  type        = string
  default     = "eks-hybrid/terraform.tfstate"
}

variable "calico_namespace" {
  description = "Namespace for Calico services"
  type        = string
}

variable "calico_version" {
  description = "Version of Calico to install"
  type        = string
}

variable "pod_subnets" {
  description = "Mapping of node names to their corresponding pod subnets"
  type        = map(string)
}
