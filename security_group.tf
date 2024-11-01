# Security group allowing inbound port 80
resource "aws_security_group" "sg_nat_instance" {
  name        = "sg_nat_instanc"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.tamnt1-vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["118.69.61.83/32"]
  }
  ingress {
    description = "Allow traffic from private subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet_us-east-2a.cidr_block, aws_subnet.private_subnet_us-east-2b.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_nat_instance"
  }
}

output "security_group_id" {
  description = "ID of the HTTP security group"
  value       = aws_security_group.sg_nat_instance.id
}

resource "aws_security_group" "sg_private" {
  name        = "mysql_sg"
  description = "Allow MySQL inbound traffic"
  vpc_id      = aws_vpc.tamnt1-vpc.id

  ingress {
    description = "MySQL from anywhere"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["118.69.61.83/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql_sg"
  }
}



# Create ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.tamnt1-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}
