terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  default_tags {
    Executor        = "Terraform"
    ApplicationType = "S3 static website"
    ApplicationHost = "AWS"
  }
}
