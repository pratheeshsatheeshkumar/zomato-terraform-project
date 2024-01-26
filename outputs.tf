output "frontend-public_ip" {
  value = aws_instance.zomato-prod-frontend.public_ip
}

output "webserver-public-ip-ssh" {   
  value = "ssh -i mykey ec2-user@${aws_instance.zomato-prod-frontend.public_ip}"
}


output "webserver-public-dns" {
  value = aws_instance.zomato-prod-frontend.public_dns
}