#network.tf
#-------------------------

variable "region" {
  #  default = "us-east-1"
  default = "us-east-1"
}

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
variable "subnetPub_AZ_ACIDRblock" {
  default = "10.132.0.0/24"
}

variable "subnetPub_AZ_BCIDRblock" {
  default = "10.132.1.0/24"
}

variable "subnetPriv_AZ_ACIDRblock" {
  default = "10.132.2.0/24"
}

variable "subnetPriv_AZ_BCIDRblock" {
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
  default = "0.0.0.0/0"
}


#ec2.tf
#-------------------------
variable "amiWordpress" {
  #AMI Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  default = "ami-0149b2da6ceec4bb0"
}

variable "instanceTypeWordpress" {
  default = "t2.micro"
}

variable "chaveSSH" {
  default = "devops"
}