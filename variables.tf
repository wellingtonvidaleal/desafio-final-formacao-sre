#main.tf
#-------------------------

variable "region" {
#  default = "us-east-1"
  default = "us-east-1"
}

#vpc.tf
#-------------------------

variable "vpcCIDRblock" {
  default = "10.132.0.0/16"
}

variable "vpcInstanceTenancy" {
  default = "default"
}

variable "vpcDnsSupport" {
  default = true
}

variable "vpcDnsHostNames" {
  default = true
}

#Sub-redes
variable "subnetPub-AZ-ACIDRblock" {
  default = "10.132.0.0/24"
}

variable "subnetPub-AZ-BCIDRblock" {
  default = "10.132.1.0/24"
}

variable "subnetPriv-AZ-ACIDRblock" {
  default = "10.132.2.0/24"
}

variable "subnetPriv-AZ-BCIDRblock" {
  default = "10.132.3.0/24"
}

variable "availabilityZoneA" {
  #default = "us-east-1a"
  default = "us-east-1a"
}

variable "availabilityZoneB" {
  #default = "us-east-1b"
  default = "us-east-1b"
}

variable "mapPublicIPPublicas" {
  default = true
}

variable "mapPublicIPPrivadas" {
  default = false
}

variable "ipsDeDestinosPublicosCIDRblock" {
  default = "0.0.0.0/0"
}

variable "redeDaVPCCIDRblock" {
  default = "10.132.0.0/16"
}

variable "balanceadorDeCarga" {
  default = "0.0.0.0/0" #Substituir pelo IP do balanceador de carga
}

variable "meuIP" {
  default = "138.204.27.165/32"
}