provider "aws" {
  region = "us-east-1"


}

resource "aws_instance" "my-first-server" {
  ami           = "ami-08c40ec9ead489470"
  instance_type = "t2.micro"
  tags = {
    Name = "ubuntu"
  }
}

# # example on how to create a VPC
# resource "aws_vpc" "first-vpc" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "production"
#   }
# }

# # example on how to create a subnet
# resource "aws_subnet" "subnet" {
#   vpc_id     = aws_vpc.first-vpc.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "prod-subnet"
#   }
# }

# Exercise 
# 1. Create a VPC(virtual Private Cloud)

resource "aws_vpc" "jadashi1-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "production"
  }
}

# 2. Create an Internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.jadashi1-vpc.id
}

# 3. Create a custom route table 
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.gw.id
  }

  tags = {
    Name = "Production"
  }
}

# 4. Create a subnet
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.jadashi1-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Production-subnet"
  }
}

# 5. Associate subnet with a route table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description      = "SSH"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_Web"
  }
}
