terraform {
  required_version = "~> 1.10"

  backend "s3" {
    bucket         = "agileops-tf-states"
    key            = "mesh-vpn/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.0"
    }
  }
}

provider "aws" {
  region = var.region
}
