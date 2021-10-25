
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
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tf-example"
  }
}
  
 resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/16"
  

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "my_vpc" {
  subnet_id   = aws_subnet.my_subnet.id
  
}

  module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "Docker"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = aws_vpc.my_vpc.id

  ingress_cidr_blocks = ["10.10.0.0/16"]
   
}
/*
 module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance"

  ami                    = "ami-074cce78125f09d61"
  instance_type          = "t2.micro"
  
  user_data              = file("file.sh") 
  monitoring             = true
  vpc_security_group_ids = module.web_server_sg.security_group_id
  subnet_id              = aws_subnet.my_subnet.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}   
 */   
  

resource "aws_instance" "my_vpc" {
  ami             = "ami-074cce78125f09d61" 
  instance_type   = "t2.micro"
  user_data	= file("file.sh") 
  network_interface {
  network_interface_id = aws_network_interface.my_vpc.id
  device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

