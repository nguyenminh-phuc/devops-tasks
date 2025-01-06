terraform {
  required_version = "~> 1.10"

  backend "s3" {
    bucket         = "agileops-tf-states"
    key            = "producer-consumer/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}
