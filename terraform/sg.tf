# Create security group for web tier
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for web tier"
  vpc_id      = aws_vpc.vpc.id

  # Ingress rule for HTTP traffic from the ALB security group
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Ingress rule for SSH traffic from a specific IP range (example)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  # Egress rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create security group for intermediate access from app tier to ILB
resource "aws_security_group" "app_ilb_intermediate_sg" {
  name        = "app-ilb-intermediate-sg"
  description = "Intermediate security group for app tier to ILB access"
  vpc_id      = aws_vpc.vpc.id

  # Ingress rule for HTTP traffic from the ILB security group
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    security_groups = [aws_security_group.ilb_sg.id]
  }

  # Egress rule allowing all traffic to the app tier security group
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups = [aws_security_group.app_sg.id]
  }
}

# Create security group for app tier
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for app tier"
  vpc_id      = aws_vpc.vpc.id

  # Ingress rule for HTTP traffic from the intermediate security group
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    security_groups = [aws_security_group.app_ilb_intermediate_sg.id]
  }

  # Ingress rule for SSH traffic from a specific IP range (example)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  # Egress rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create security group for ILB
resource "aws_security_group" "ilb_sg" {
  name        = "ilb-sg"
  description = "Security group for ILB"
  vpc_id      = aws_vpc.vpc.id

  # Ingress rule for HTTP traffic from the app tier security group
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    security_groups = [aws_security_group.app_ilb_intermediate_sg.id]
  }

  # Egress rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create public subnets
resource "aws_subnet" "public_subnet" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone = element(var.availability_zones, count.index)
}

# Create private subnets
resource "aws_subnet" "private_subnet" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = element(var.availability_zones, count.index)
}