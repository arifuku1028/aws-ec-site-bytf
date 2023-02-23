terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    region  = "ap-northeast-1"
    bucket  = "terraform-backend-0000002"
    key     = "demo-arifuku.tfstate"
    encrypt = true
  }
}
