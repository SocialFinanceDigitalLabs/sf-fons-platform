data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.environment
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name     = var.environment
    Function = "Dagster"
  }
}

resource "aws_internet_gateway_attachment" "internet_gateway_attachment" {
  vpc_id              = aws_vpc.vpc.id
  internet_gateway_id = aws_internet_gateway.internet_gateway.id
}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(data.aws_availability_zones.available.names, 0)
  cidr_block              = var.public_subnet1_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment} Public Subnet (AZ1)"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(data.aws_availability_zones.available.names, 1)
  cidr_block              = var.public_subnet2_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment} Public Subnet (AZ2)"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(data.aws_availability_zones.available.names, 0)
  cidr_block              = var.private_subnet1_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment} Private Subnet (AZ1)"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(data.aws_availability_zones.available.names, 1)
  cidr_block              = var.private_subnet2_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment} Private Subnet (AZ2)"
  }
}

resource "aws_eip" "nat_gateway1_eip" {
  domain = "vpc"
}

resource "aws_eip" "nat_gateway2_eip" {
  domain = "vpc"
}

resource "aws_eip" "nat_gateway_database_eip1" {
  domain = "vpc"
}

resource "aws_eip" "nat_gateway_database_eip2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat_gateway1_eip.id
  subnet_id     = aws_subnet.private_subnet1.id
}

resource "aws_nat_gateway" "nat_gateway2" {
  allocation_id = aws_eip.nat_gateway2_eip.id
  subnet_id     = aws_subnet.private_subnet2.id
}

resource "aws_nat_gateway" "nat_gateway_database1" {
  allocation_id = aws_eip.nat_gateway_database_eip1.id
  subnet_id     = aws_subnet.database_subnet_1.id
}

resource "aws_nat_gateway" "nat_gateway_database2" {
  allocation_id = aws_eip.nat_gateway_database_eip2.id
  subnet_id     = aws_subnet.database_subnet_2.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment} Public Routes"
  }
}

resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public_subnet1_route_table_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet2_route_table_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table1" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment} Private Routes (AZ1)"
  }
}

resource "aws_route" "default_private_route1" {
  route_table_id         = aws_route_table.private_route_table1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway1.id
}

resource "aws_route_table_association" "private_subnet1_route_table_association" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table1.id
}

resource "aws_route_table" "private_route_table2" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment} Private Routes (AZ2)"
  }
}

resource "aws_route" "default_private_route2" {
  route_table_id         = aws_route_table.private_route_table2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway2.id
}

resource "aws_route_table_association" "private_subnet2_route_table_association" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table2.id
}

resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${data.aws_region.current}.s3"

  route_table_ids = [
    aws_route_table.private_route_table1.id,
    aws_route_table.private_route_table2.id
  ]
}

resource "aws_vpc_endpoint_policy" "s3_gateway_endpoint_policy" {
  vpc_endpoint_id = aws_vpc_endpoint.s3_gateway_endpoint.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectAttributes",
          "s3:GetObjectAcl",
          "s3:GetBucketLocation",
          "s3:ListBucketVersions",
        ],
        Resource = [
          var.data_store_bucket,
          var.workspace_bucket,
          var.shared_bucket,
          "${var.data_store_bucket}/*",
          "${var.workspace_bucket}/*",
          "${var.shared_bucket}/*",
        ],
      },
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:ListBucket"],
        Resource = [
          var.data_store_bucket,
          var.workspace_bucket,
          var.shared_bucket,
        ],
      },
    ],
  })
}

resource "aws_vpc_endpoint" "database_interface_private_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current}.rds"
  subnet_ids          = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  security_group_ids  = [aws_security_group.daemon_security_group.id, aws_security_group.code_server_security_group.id, aws_security_group.database_security_group.id]
  private_dns_enabled = true
}

resource "aws_service_discovery_private_dns_namespace" "private_service_discovery_namespace" {
  name = "fons-namespace.local"
  vpc  = aws_vpc.vpc.id
}

resource "aws_security_group" "daemon_security_group" {
  name        = "daemon-sg-${var.environment}"
  description = "Security group for the dagster daemon"
  vpc_id      = aws_vpc.vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_security_group" "code_server_security_group" {
  name        = "codeserver-sg-${var.environment}"
  description = "Security Group for the Code Server"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 4000
    to_port         = var.code_server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.daemon_security_group.id]
  }

  ingress {
    from_port       = 4000
    to_port         = var.code_server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.dagit_security_group.id]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_security_group" "dagit_security_group" {
  name        = "dagit-sg-${var.environment}"
  description = "Security Group for the Dagit Interface"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3000
    to_port     = var.dagit_host_port
    protocol    = "tcp"
    cidr_blocks = [var.dagit_sg_cidr]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database Subnet Group
resource "aws_db_subnet_group" "database_subnet_group" {
  name        = "${var.environment}-db-subnet-group"
  description = "Subnet group for Aurora"
  subnet_ids  = [aws_subnet.database_subnet_1.id, aws_subnet.database_subnet_2.id]
}

# Database Subnets
resource "aws_subnet" "database_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.database_subnet_cidr1
  availability_zone       = element(data.aws_availability_zones.available.names, 0)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.environment} Database Subnet 1"
  }
}

resource "aws_subnet" "database_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.database_subnet_cidr2
  availability_zone       = element(data.aws_availability_zones.available.names, 1)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.environment} Database Subnet 2"
  }
}

# Nat Gateways for Database
resource "aws_nat_gateway" "nat_gateway_database_1" {
  allocation_id = aws_eip.nat_gateway_database_eip_1.id
  subnet_id     = aws_subnet.database_subnet_1.id
}

resource "aws_nat_gateway" "nat_gateway_database_2" {
  allocation_id = aws_eip.nat_gateway_database_eip_2.id
  subnet_id     = aws_subnet.database_subnet_2.id
}

# EIPs for Nat Gateways Database
resource "aws_eip" "nat_gateway_database_eip_1" {
  domain = "vpc"
}

resource "aws_eip" "nat_gateway_database_eip_2" {
  domain = "vpc"
}

# Route Tables for Private Subnets Database
resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment} Private Routes (AZ1)"
  }
}

resource "aws_route" "default_private_route_1" {
  route_table_id         = aws_route_table.private_route_table_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_database_1.id
}

resource "aws_route_table_association" "private_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.database_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment} Private Routes (AZ2)"
  }
}

resource "aws_route" "default_private_route_2" {
  route_table_id         = aws_route_table.private_route_table_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_database_2.id
}

resource "aws_route_table_association" "private_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.database_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id
}

# Security Group for Database
resource "aws_security_group" "database_security_group" {
  name        = "${var.environment}-database-sg"
  description = "Security Group for the database"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "database_security_group_code_server_ingress" {
    from_port = var.database_port
    to_port   = var.database_port
    ip_protocol  = "tcp"
  security_group_id = aws_security_group.database_security_group
    referenced_security_group_id = aws_security_group.code_server_security_group.id
}

resource "aws_vpc_security_group_ingress_rule" "database_security_group_daemon_ingress" {
    from_port = var.database_port
    to_port   = var.database_port
    ip_protocol  = "tcp"
  security_group_id = aws_security_group.database_security_group
    referenced_security_group_id = aws_security_group.daemon_security_group.id
}

resource "aws_vpc_security_group_ingress_rule" "database_security_group_dagit_ingress" {
    from_port = var.database_port
    to_port   = var.database_port
    ip_protocol  = "tcp"
    security_group_id = aws_security_group.database_security_group
    referenced_security_group_id = aws_security_group.dagit_security_group.id
}

resource "aws_vpc_security_group_egress_rule" "database_security_group_egress" {
    from_port   = 0
    to_port     = 0
    ip_protocol    = "-1"
    cidr_ipv4 = "0.0.0.0/0"
    security_group_id = aws_security_group.database_security_group.id
}

# S3 Interface Private Endpoint
resource "aws_vpc_endpoint" "s3_interface_private_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current}.s3"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.database_subnet_1.id, aws_subnet.database_subnet_2.id]
  security_group_ids = [
    aws_security_group.daemon_security_group.id,
    aws_security_group.code_server_security_group.id,
  ]
  private_dns_enabled = true
}


