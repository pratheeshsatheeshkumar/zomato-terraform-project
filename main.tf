resource "aws_vpc" "zomato-prod-vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    "Name" = "${var.project}-${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.zomato-prod-vpc.id

  tags = {
    "Name" = "${var.project}-${var.env}-igw"
  }
}

resource "aws_subnet" "zomato-prod-public1" {
  vpc_id                  = aws_vpc.zomato-prod-vpc.id
  cidr_block              = var.zomato-prod-public1-config.cidr
  availability_zone       = var.zomato-prod-public1-config.az
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.project}-${var.env}-public1"
  }
}
resource "aws_subnet" "zomato-prod-public2" {
  vpc_id                  = aws_vpc.zomato-prod-vpc.id
  cidr_block              = var.zomato-prod-public2-config.cidr
  availability_zone       = var.zomato-prod-public2-config.az
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.project}-${var.env}-public2"
  }
}

resource "aws_subnet" "zomato-prod-private1" {
  vpc_id                  = aws_vpc.zomato-prod-vpc.id
  cidr_block              = var.zomato-prod-private1-config.cidr
  availability_zone       = var.zomato-prod-private1-config.az
  map_public_ip_on_launch = false

  tags = {
    "Name" = "${var.project}-${var.env}-private1"
  }
}
/*  
resource "aws_eip" "zomato-prod-eip-nat" {
  domain = "vpc"
  tags = {
    "Name" = "${var.project}-${var.env}-eip-nat"
  }
}
*/

/*resource "aws_nat_gateway" "zomato-prod-natgw" {
  allocation_id = aws_eip.zomato-prod-eip-nat.id
  subnet_id     = aws_subnet.zomato-prod-public2.id

  tags = {
    Name = "${var.project}-${var.env}-nat_gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}
*/

resource "aws_route_table" "zomato-prod-rt-public" {
  vpc_id = aws_vpc.zomato-prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "${var.project}-${var.env}-rt-public"
  }
}

/*
resource "aws_route_table" "zomato-prod-rt-private" {
  vpc_id = aws_vpc.zomato-prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.zomato-prod-natgw.id
  }

  tags = {
    Name = "${var.project}-${var.env}-rt-private"
  }
}
*/
resource "aws_route_table_association" "zomato-prod-rt_subnet-assoc1" {
  subnet_id      = aws_subnet.zomato-prod-public1.id
  route_table_id = aws_route_table.zomato-prod-rt-public.id
}

resource "aws_route_table_association" "zomato-prod-rt_subnet-assoc2" {
  subnet_id      = aws_subnet.zomato-prod-public2.id
  route_table_id = aws_route_table.zomato-prod-rt-public.id
}
/*
resource "aws_route_table_association" "zomato-prod-rt_subnet-assoc3" {
  subnet_id      = aws_subnet.zomato-prod-private1.id
  route_table_id = aws_route_table.zomato-prod-rt-private.id
}
*/



resource "aws_key_pair" "aws-keypair" {
  key_name   = "${var.project}-${var.env}-keypair"
  public_key = file("/home/ubuntu/keys/aws_key.pub")
  tags = {
    "Name" = "${var.project}-${var.env}-keypair"
  }
}



#Creation of security group for zomato-frontend

resource "aws_security_group" "zomato-prod-frontend-sg" {
  name_prefix = "${var.project}-${var.env}-frontend-sg-"
  description = "allow http, https and ssh traffic"
  vpc_id      = aws_vpc.zomato-prod-vpc.id
 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ tags ]
    
  }

  tags = {
    "Name" = "${var.project}-${var.env}-frontend-sg"
  }
}

#Addition of ingress sg rules to zomato-prod-frontend-sg 
resource "aws_security_group_rule" "frontend-rules" {
  for_each = toset(var.port_list)
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = aws_security_group.zomato-prod-frontend-sg.id
}




#Creation of security group for zomato-bastion

resource "aws_security_group" "zomato-prod-bastion-sg" {
  name_prefix = "${var.project}-${var.env}-bastion-sg-"
  description = "allow http, https and ssh traffic"
  vpc_id      = aws_vpc.zomato-prod-vpc.id

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
    "Name" = "${var.project}-${var.env}-bastion-sg"
  }
}

#creation of backend security group

resource "aws_security_group" "zomato-prod-backend-sg" {
  name_prefix = "${var.project}-${var.env}-backend-sg-"
  description = "allow sql and ssh traffic"
  vpc_id      = aws_vpc.zomato-prod-vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.zomato-prod-frontend-sg.id]


  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.zomato-prod-bastion-sg.id]
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
    "Name" = "${var.project}-${var.env}-backend-sg"
  }
}


# Instance creation of zomato-prod-frontend

resource "aws_instance" "zomato-prod-frontend" {
  ami                         = var.instance_ami
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.zomato-prod-public1.id
  instance_type               = var.instance_type
  key_name                    = "${var.project}-${var.env}-keypair"
  vpc_security_group_ids      = [aws_security_group.zomato-prod-frontend-sg.id]
  tags = {
    "Name" = "${var.project}-${var.env}-frontend"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("/home/ubuntu/keys/aws_key")
    host = self.public_ip
  }
  
  
  provisioner "file" {
    source = "apache_install.sh"
    destination = "/tmp/apache_install.sh"
      
  }

  provisioner "remote-exec" {
       
    inline = [
      "sudo chmod +x /tmp/apache_install.sh",
      "sudo /tmp/apache_install.sh"
      ]  
  }
 
}


# Instance creation of zomato-prod-bastion
/*
resource "aws_instance" "zomato-prod-bastion" {
  ami                         = var.instance_ami
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.zomato-prod-public2.id
  instance_type               = var.instance_type
  key_name                    = "${var.project}-${var.env}-keypair"
  vpc_security_group_ids      = [aws_security_group.zomato-prod-bastion-sg.id]
  tags = {
    "Name" = "${var.project}-${var.env}-bastion"
  }
}

# Instance creation of zomato-prod-backend

resource "aws_instance" "zomato-prod-backend" {
  ami                         = var.instance_ami
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.zomato-prod-private1.id
  instance_type               = var.instance_type
  key_name                    = "${var.project}-${var.env}-keypair"
  vpc_security_group_ids      = [aws_security_group.zomato-prod-backend-sg.id]
  
  depends_on = [ aws_nat_gateway.zomato-prod-natgw ]
  
  tags = {
    "Name" = "${var.project}-${var.env}-backend"
  }
}
*/