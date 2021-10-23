/*
module "vpc1" {
  source = "terraform-aws-modules/vpc/aws"
  name = "prodvpc"
  cidr = "10.0.0.0/24"
}

  
module "vpc2" {
  source = "terraform-aws-modules/vpc/aws"
  name = "Nonprodvpc"
  cidr = "10.0.0.0/24"
}
 */ 
    
  
  
  
  
  resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "tf-example"
  }
}
  
 resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  

  tags = {
    Name = "primary_network_interface"
  }
}

  module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "Docker"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = aws_vpc.my_vpc.id

  ingress_cidr_blocks = ["10.10.0.0/16"]
}


resource "aws_instance" "app_server" {
  ami             = "ami-074cce78125f09d61" 
  instance_type   = "t2.micro"
  key_name        = "vicky"
  user_data	= file("file.sh")
  security_groups = [ "Docker" ]

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

