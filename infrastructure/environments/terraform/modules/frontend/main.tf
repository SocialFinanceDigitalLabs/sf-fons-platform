
resource "tls_private_key" "frontend_private_key"{
  algorithm = "ED25519"  # RSA, ECDSA, or ED25519
}

resource "aws_key_pair" "frontend_key_pair" {
  key_name = "FrontendKeyPair"
  public_key = tls_private_key.frontend_private_key.public_key_openssh
}

resource "aws_iam_instance_profile" "frontend_ec2_instance_profile" {
  name = "FrontendEC2InstanceProfile"

  role = aws_iam_role.frontend_ec2_role.name
}

resource "aws_instance" "frontend_ec2_instance" {
  ami                  = var.FrontendEC2Image
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.frontend_key_pair.key_name
  iam_instance_profile = aws_iam_instance_profile.frontend_ec2_instance_profile.name
  user_data            = <<-EOF
                            #!/bin/bash -xe
                            yum update -y
                            yum install -y docker
                            yum install -y amazon-cloudwatch-agent
                            service docker start
                            systemctl enable docker
                            usermod -a -G docker ec2-user
                            aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin ${var.FrontendRepoUri}
                            docker pull ${var.FrontendRepoUri}/${var.FrontendRepoName}:${var.FrontendRepoVersion}
                            docker run -d -p 0.0.0.0:80:8000 -e AWS_REGION=${data.aws_region} \
                                -e AWS_COGNITO_USER_POOL_ID=${var.CognitoUserPoolId} \
                                -e AWS_COGNITO_APP_CLIENT_ID=${var.CognitoAppClientId} \
                                -e AWS_COGNITO_DOMAIN=${var.CognitoAppDomain} \
                                -e DJANGO_SECRET_KEY=${var.SecretKey} \
                                -e SF_FS_BACKEND_URL=${var.DataStoreLocation} \
                                ${var.FrontendRepoUri}/${var.FrontendRepoName}:${var.FrontendRepoVersion}
                            EOF

  network_interface {
    associate_public_ip_address = true
    device_index                = 0

    security_groups = [aws_security_group.frontend_security_group.id]
    subnet_id       = aws_subnet.frontend_public_subnet_1.id
  }
}

resource "aws_iam_role" "frontend_ec2_role" {
  name = "FrontendEC2Role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]

  inline_policy {
      name   = "FrontendCloudWatchLogsPolicy"
      policy = data.aws_iam_policy_document.frontend_cloudwatch_logs_policy.json
    }

  inline_policy {
    name   = "FrontendEC2Policy"
    policy = data.aws_iam_policy_document.frontend_ec2_policy.json
  }
}

data "aws_iam_policy_document" "frontend_cloudwatch_logs_policy" {
  statement {
    actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "frontend_ec2_policy" {
  statement {
    actions = [
      "ec2-instance-connect:SendSSHPublicKey"
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      variable = "ec2:osuser"
      values = [
        "ec2-user"
      ]
    }
  }

  statement {
    actions = [
      "ec2:DescribeInstances"
    ]
    resources = ["*"]
  }
}

resource "aws_security_group" "frontend_security_group" {
  name        = "frontend-sg-${var.Environment}"
  description = "Enable HTTP access"
  vpc_id      = aws_vpc.frontend_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "frontend_vpc" {
  cidr_block           = var.FrontendVpcCIDR
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.Environment
  }
}

resource "aws_lb_target_group" "frontend_target_group" {
  name     = "FrontendTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.frontend_vpc.id

  target_type = "instance"

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "traffic-port"
  }
}

resource "aws_lb" "frontend_alb" {
  name               = "frontend-alb-${var.Environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_security_group.id]
  subnets            = [aws_subnet.frontend_public_subnet_1.id, aws_subnet.frontend_public_subnet_2.id]

  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

  enable_http2 = true
}

resource "aws_lb_listener" "frontend_listener" {
  default_action {
    type = "redirect"

    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"
}

resource "aws_lb_listener" "frontend_https_listener" {
  default_action {
    type = "forward"

    forward {
      target_group_arn = aws_lb_target_group.frontend_target_group.arn
      weight           = 1
    }
  }

  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = var.FonsSSLCertificateARN
}

resource "aws_route_table" "frontend_route_table" {
  vpc_id = aws_vpc.frontend_vpc.id
  tags = {
    Name = "${var.Environment} Frontend Routes"
  }
}

resource "aws_route" "frontend_route" {
  route_table_id         = aws_route_table.frontend_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.frontend_internet_gateway.id
}

resource "aws_route_table_association" "public_subnet1_route_table_association" {
  subnet_id      = aws_subnet.frontend_public_subnet_1.id
  route_table_id = aws_route_table.frontend_route_table.id
}

resource "aws_route_table_association" "public_subnet2_route_table_association" {
  subnet_id      = aws_subnet.frontend_public_subnet_2.id
  route_table_id = aws_route_table.frontend_route_table.id
}

resource "aws_internet_gateway" "frontend_internet_gateway" {
  vpc_id = aws_vpc.frontend_vpc.id

  tags = {
    Name     = var.Environment
    Function = "Frontend"
  }
}

resource "aws_internet_gateway_attachment" "frontend_internet_gateway_attachment" {
  vpc_id              = aws_vpc.frontend_vpc.id
  internet_gateway_id = aws_internet_gateway.frontend_internet_gateway.id
}

resource "aws_subnet" "frontend_public_subnet_1" {
  vpc_id                  = aws_vpc.frontend_vpc.id
  availability_zone       = element(data.aws_availability_zones.available.names, 0)
  cidr_block              = var.PublicSubnet1CIDR
  map_public_ip_on_launch = true

  tags = {
    Name = format("%s Public Subnet for Website (AZ1)", var.Environment)
  }
}

resource "aws_subnet" "frontend_public_subnet_2" {
  vpc_id                  = aws_vpc.frontend_vpc.id
  availability_zone       = element(data.aws_availability_zones.available.names, 1)
  cidr_block              = var.PublicSubnet2CIDR
  map_public_ip_on_launch = true

  tags = {
    Name = format("%s Public Subnet for Website (AZ1)", var.Environment)
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}