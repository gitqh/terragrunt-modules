resource "aws_instance" "bastion" {
  ami                         = "ami-08569b978cc4dfa10"
  key_name                    = "${var.bastion_key}"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.bastion-sg.id}"]
  subnet_id                   = "${local.bastion_subnet_id}"
  associate_public_ip_address = true
}

resource "aws_security_group" "bastion-sg" {
  name   = "${var.platform}-bastion-security-group"
  vpc_id = "${local.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
