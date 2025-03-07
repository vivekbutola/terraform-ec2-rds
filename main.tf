# Generate a new RSA key pair
resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a new AWS key pair using the generated public key
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key"
  public_key = tls_private_key.generated.public_key_openssh
}

# Save the private key locally for SSH access
resource "local_file" "private_key" {
  content  = tls_private_key.generated.private_key_pem
  filename = "${path.module}/terraform-key.pem"
  file_permission = "0600"
}

# Create Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "terraform-sg"
  description = "Allow SSH and necessary ports"
  vpc_id      = aws_vpc.terraform_vpc.id

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

# Create Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "terraform-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "Terraform-RDS-SG"
  }
}

# Create VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Terraform-VPC"
  }
}

# Create Private Subnet 1 (ap-south-1a)
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "Terraform-Private-Subnet-1"
  }
}

# Create Private Subnet 2 (ap-south-1b) for Multi-AZ RDS
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-south-1b"

  tags = {
    Name = "Terraform-Private-Subnet-2"
  }
}

# Create DB Subnet Group with Two AZs
resource "aws_db_subnet_group" "terraform_db_subnet_group" {
  name       = "terraform-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "Terraform-DB-Subnet-Group"
  }
}

# Create EC2 Instance with Key Pair
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0d682f26195e9ec0f"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = aws_subnet.private_subnet_1.id

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "Terraform-EC2"
  }
}

# Create RDS Instance
resource "aws_db_instance" "terraform_rds" {
  allocated_storage         = 30
  storage_type              = "gp2"
  engine                    = "mysql"
  engine_version            = "8.0.40"
  instance_class            = "db.t3.micro"
  identifier                = "terraform-db"
  db_name                   = "terraform"
  username                  = "terraform"
  password                  = "h2wWcGcAoFc08MV;7L:U"
  publicly_accessible       = false
  vpc_security_group_ids    = [aws_security_group.rds_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.terraform_db_subnet_group.name
  multi_az                  = false
  backup_retention_period   = 7
  skip_final_snapshot       = true

  tags = {
    Name = "Terraform-RDS"
  }
}

# Generate a unique string for S3 bucket name
resource "random_string" "s3_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create S3 Bucket with Unique Name
resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "terraform-sandbox-bucket-${random_string.s3_suffix.result}"

  tags = {
    Name = "Terraform S3"
  }
}
