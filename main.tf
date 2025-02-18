terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74"
    }
  }
}

# Specify the provider (AWS)
provider "aws" {
  region = "us-east-1"  # Change as needed
# add access and secret access key herels

}

# Create a new key pair for SSH access
# create keypair using ssh-keygen -t rsa -b 2048 -f ~/.ssh/<filename>
resource "aws_key_pair" "daily" {
  key_name   = "daily"
  public_key = file("~/.ssh/daily.pub")  # Use your actual SSH key
}

# Create a security group to allow SSH and HTTP access
resource "aws_security_group" "my_sg" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all (adjust for security)
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# Create an EC2 instance
resource "aws_instance" "my_instance" {
  ami             = "ami-04b4f1a9cf54c11d0"  # Amazon Linux 2 AMI (update as needed)
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.daily.daily
  security_groups = [aws_security_group.my_sg.name]

  tags = {
    Name = "Terraform-EC2"
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}
