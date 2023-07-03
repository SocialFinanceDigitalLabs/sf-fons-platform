resource "aws_vpc" "platform" {
  cidr_block = var.vpc_cidr

  tags = {
    env = var.environment
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.platform.id
  cidr_block = var.public_subnet_1_cidr

  tags = {
    env = var.environment
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.platform.id
  cidr_block = var.public_subnet_2_cidr

  tags = {
    env = var.environment
  }
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.platform.id
  cidr_block = var.private_subnet_1_cidr

  tags = {
    env = var.environment
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.platform.id
  cidr_block = var.private_subnet_2_cidr

  tags = {
    env = var.environment
  }
}




resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.platform.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.platform.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.platform.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}