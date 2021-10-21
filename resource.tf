module "vpc1" {
  source = "terraform-aws-modules/vpc/aws"
  name = "prodvpc"
  cidr = "10.0.0.0/16"
}

  
module "vpc2" {
  source = "terraform-aws-modules/vpc/aws"
  name = "Nonprodvpc"
  cidr = "10.0.0.0/16"
}
  
  /*
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  ami                    = "ami-074cce78125f09d61"
  instance_type          = "t2.micro"
 
}

*/

