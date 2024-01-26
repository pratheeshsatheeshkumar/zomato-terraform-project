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