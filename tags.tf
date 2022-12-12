locals {
  wordpress_tags = {
    owner       = "development"
    service     = "wordpress"
    cost-center = "5678"
  }

  infra_tags = {
    owner       = "operations"
    service     = "core-infra"
    cost-center = "1234"
  }

  monitoring_tags = {
    owner       = "operations"
    service     = "monitoring"
    cost-center = "9101"
  }
  
  security_tags = {
    owner       = "cloud-sec"
    service     = "core-security"
    cost-center = "1213"
  }
}