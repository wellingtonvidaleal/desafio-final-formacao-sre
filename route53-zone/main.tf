terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      environment = var.environment
      created-by  = "terraform"
    }
  }
}

resource "aws_route53_zone" "primary" {
  name          = "wellingtonvidaleal.com.br"
  force_destroy = false

  tags = {
    owner       = "operations"
    service     = "core-infra"
    cost-center = "1234"
  }
}