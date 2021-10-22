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
  cidr_block        = "172.16.10.0/24"
  

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}
  
  resource "aws_security_group" "Docker" {
  name        = "Docker"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

    
  ingress = [
    {
      description      = "TLS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/24"]
      
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["10.0.0.0/24"]
      
    }
  ]

  tags = {
    Name = "Docker"
  }
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

