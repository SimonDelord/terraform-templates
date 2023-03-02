terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}


resource "aws_default_subnet" "default_az1" {
   availability_zone = var.aws_zone
   tags =  {
     Name = "default subnet for default vpc"
   }
}


resource "aws_instance" "app_server" {
  ami           = "ami-0f2eac25772cd4e36"
  instance_type = "m5.xlarge"
  subnet_id = aws_default_subnet.default_az1.id
  key_name      = "rhpds-key-27-02-23"
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.forwarder.id]
  
  user_data = <<-EOL
  #!/bin/bash -xe
  sudo yum install yum-utils -y
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  sudo yum install terraform -y
  sudo wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux-4.12.5.tar.gz
  EOL
  
  tags = {
    Name = "JumphostWithEverything"
  }
}


resource "aws_security_group" "forwarder" {
#  vpc_id = "vpc-06b4aa0406ef23d4d"
  vpc_id = aws_default_vpc.default.id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
