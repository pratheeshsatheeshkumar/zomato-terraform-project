variable "project" {
  default     = "zomato"
  description = "name of the project"

}

variable "env" {
  default     = "prod"
  description = "environment of the project"

}

variable "region" {
  default     = "ap-south-1"
  description = "aws region"
}

variable "instance_ami" {
  default = "ami-0c84181f02b974bc3"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_cidr_block" {
  default = "172.17.0.0/16"
}

variable "zomato-prod-public1-config" {
  type = map(any)
  default = {
    cidr = "172.17.0.0/18"
    az   = "ap-south-1a"
  }
}

variable "zomato-prod-public2-config" {
  type = map(any)
  default = {
    cidr = "172.17.64.0/18"
    az   = "ap-south-1b"
  }
}

variable "zomato-prod-private1-config" {
  type = map(any)
  default = {
    cidr = "172.17.128.0/18"
    az   = "ap-south-1b"
  }
}