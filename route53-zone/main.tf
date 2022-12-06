terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

resource "aws_route53_zone" "primary" {
  name          = "wellingtonvidaleal.com.br"
  force_destroy = false
}