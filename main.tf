resource "aws_instance" "zomato-frontend" {
  ami                    = "ami-0c84181f02b974bc3"
  associate_public_ip_address = true
  subnet_id = "subnet-06215c494549b1531"
  instance_type          = "t2.micro"
  key_name               = "yespratheeshdevops"
  vpc_security_group_ids = ["sg-0406f3931b3187f8c"]
  tags = {
    "Name"    = "zomato-frontend"
    "project" = "zomato"
    "env"     = "prod"
  }
}