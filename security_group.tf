resource "aws_security_group" "instance" {
  name        = "${var.environment}_allow_default"
  description = "Security group for ssh and application access"
  vpc_id      = "${aws_vpc.infra.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

output "InstanceSecGroupID" {
  value = "${aws_security_group.instance.id}"
}

resource "aws_security_group" "elb" {
  name        = "${var.environment}_allow_elb_default"
  description = "Security group for application access for elb"
  vpc_id      = "${aws_vpc.infra.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
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

output "ELBSecGroupID" {
  value = "${aws_security_group.elb.id}"
}
