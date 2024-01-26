resource "aws_key_pair" "aws-keypair" {
  key_name   = "${var.project}-${var.env}-keypair"
  public_key = file("/home/ubuntu/keys/aws_key.pub")
  tags = {
    "Name"    = "${var.project}-${var.env}-keypair"
    "project" = var.project
    "env"     = var.env
  }
}


#Creation of security group for zomato-frontend

resource "aws_security_group" "zomato-prod-frontend-sg" {
  name        = "${var.project}-${var.env}-frontend-sg"
  description = "allow http, https and ssh traffic"
  vpc_id      = "vpc-0946a3f4d24871189"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name"    = "${var.project}-${var.env}-frontend-sg"
    "project" = var.project
    "env"     = var.env
  }
}

# Instance creation of zomato-prod-frontend

resource "aws_instance" "zomato-prod-frontend" {
  ami                         = var.instance_ami
  associate_public_ip_address = true
  subnet_id                   = "subnet-06215c494549b1531"
  instance_type               = var.instance_type
  key_name                    = "${var.project}-${var.env}-keypair"
  vpc_security_group_ids      = [aws_security_group.zomato-prod-frontend-sg.id]
  tags = {
    "Name"    = "${var.project}-${var.env}-frontend"
    "project" = var.project
    "env"     = var.env
  }
}