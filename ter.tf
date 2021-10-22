
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

resource "aws_security_group" "Docker" {
  tags = {
    type = "terraform-test-security-group"
  }
}
