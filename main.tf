provider "aws" {
  region     = "us-east-2"
  access_key = "A"
  secret_key = "3"
}


#Create a VPC

resource "aws_vpc" "prodvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "production_vpc"
  }
}

#Create a Subnet

resource "aws_subnet" "prodsubnet1" {
  vpc_id     = aws_vpc.prodvpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"

  tags = {
    Name = "Prod-Subnet"
  }
}

#Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id     = aws_vpc.prodvpc.id

  tags = {
    Name = "IGW"
  }
}

#Create a Route Table

resource "aws_route_table" "prodroute" {
  vpc_id     = aws_vpc.prodvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  
  tags = {
    Name = "RT"
  }
}


#Associate a subnet with a Route Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prodsubnet1.id
  route_table_id = aws_route_table.prodroute.id
}


#Create security Group for the instance

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id     = aws_vpc.prodvpc.id

  ingress {
    description = "TLS from VPC HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


ingress {
    description = "TLS from VPC SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "TLS from VPC HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"    #any ip address/any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

#Create an Instance and add the security group to the instance

resource "aws_instance" "firstinstance" {
  ami                     = "ami-036841078a4b68e14"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.prodsubnet1.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name   = "ohio_new_kp"
  availability_zone = "us-east-2a"
  count = 5

  tags = {
    Name = "MaryAnn-Server"
  }

}
