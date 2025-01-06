terraform {
  required_version = "~> 1.10"

  backend "s3" {
    bucket         = "agileops-tf-states"
    key            = "monitoring-dashboards/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.15.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

provider "grafana" {
  url  = var.grafana_url
  auth = var.grafana_auth
}
