terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

#Definição do provider AWS, da região a ser utilizada e das tags padrões
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      environment = var.environment
      created-by  = "terraform"
    }
  }
}