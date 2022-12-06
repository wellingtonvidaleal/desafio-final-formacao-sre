#network.tf
#-------------------------

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.132.0.0/16"
}

variable "vpc_instance_tenancy" {
  type    = string
  default = "default"
}

variable "vpc_dns_support" {
  type    = bool
  default = true
}

variable "vpc_dns_host_names" {
  type    = bool
  default = true
}

#Subnets
variable "subnet_public_az_a_cidr_block" {
  type    = string
  default = "10.132.0.0/24"
}

variable "subnet_public_az_b_cidr_block" {
  type    = string
  default = "10.132.1.0/24"
}

variable "subnet_private_az_a_cidr_block" {
  type    = string
  default = "10.132.2.0/24"
}

variable "subnet_private_az_b_cidr_block" {
  type    = string
  default = "10.132.3.0/24"
}

variable "availability_zone_a" {
  type    = string
  default = "us-east-1a"
}

variable "availability_zone_b" {
  type    = string
  default = "us-east-1b"
}

variable "map_public_ip_publics" {
  type    = bool
  default = true
}

variable "map_public_ip_privates" {
  type    = bool
  default = false
}

variable "all_ips_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "my_ip" {
  type    = string
  default = "0.0.0.0/0"
}

#ec2.tf
#-------------------------
variable "instance_count" {
  type    = number
  default = 2
}

variable "ami_wordpress" {
  #AMI Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  type    = string
  default = "ami-0149b2da6ceec4bb0"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_key" {
  type    = string
  default = "devops"
}

#databases.tf
#-------------------------

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

#elasticache.tf
#-------------------------

variable "node_type" {
  type    = string
  default = "cache.t3.micro"
}

#load_balancer.tf
#-------------------------
/* variable "ports" {
  type = map(number)
  default = {
    http  = 80
    https = 443
  }
} */


variable "wp_home" {
  type = string
  default = "https://wellingtonvidaleal.com.br"
}

variable "wp_siteurl" {
  type = string
  default = "https://wellingtonvidaleal.com.br"
}