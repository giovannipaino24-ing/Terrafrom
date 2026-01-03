resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "devops-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "ssh_sg" {
  name   = "ssh-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  ami                    = "ami-0c38b837cd80f13bb"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  tags = {
    Name = "devops-ec2"
  }
}
