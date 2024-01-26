output "frontend-public_ip" {
  value = aws_instance.zomato-prod-frontend.public_ip
}

output "bastion-public_ip" {
  value = aws_instance.zomato-prod-bastion.public_ip
}

output "backend-public_ip" {
  value = aws_instance.zomato-prod-backend.public_ip
}

output "frontend-public-ssh" {
  value = "ssh -i mykey ec2-user@${aws_instance.zomato-prod-frontend.public_ip}"
}

output "frontend-public-ip-ssh" {
  value = "ssh -i mykey ec2-user@${aws_instance.zomato-prod-frontend.public_ip}"
}

output "frontend-instance-id" {
  value = aws_instance.zomato-prod-frontend.id
}