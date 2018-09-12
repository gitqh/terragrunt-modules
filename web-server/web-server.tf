#Script init
data "template_file" "install" {
  template = "${file("${path.module}/files//init.sh")}"

  vars {
    platform = "${var.platform}"
  }
}

data "template_cloudinit_config" "config_init" {
  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.install.rendered}"
  }
}

#ELB
resource "aws_elb" "instance" {
  name     = "${var.platform}-instance"
  internal = false

  subnets         = ["${local.server_subnet_id}"]
  security_groups = ["${aws_security_group.web-server-elb.id}"]

  instances = ["${aws_instance.server.id}"]

  idle_timeout = 3600

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  tags {
    Platform = "${var.platform}"
    Role     = "security"
    Project  = "ci5"
  }
}

# ECS Instance
resource "aws_instance" "server" {
  ami                    = "ami-08569b978cc4dfa10"
  key_name               = "${var.bastion_key}"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.web-server-sg.id}"]
  subnet_id              = "${local.server_subnet_id}"
  user_data              = "${data.template_cloudinit_config.config_init.rendered}"
}

# EIP
resource "aws_eip" "server_eip" {
  instance = "${aws_instance.server.id}"
  vpc      = true
}

# Security Group + Security rule
resource "aws_security_group" "web-server-sg" {
  name   = "${var.platform}-server-security-group"
  vpc_id = "${local.vpc_id}"

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = ["${aws_security_group.web-server-elb.id}"]
  }
}

resource "aws_security_group_rule" "ssh-bastion-to-server" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.web-server-sg.id}"
  source_security_group_id = "${local.bastion_sg_id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}

resource "aws_security_group" "web-server-elb" {
  name   = "${var.platform}-server-elb-security-group"
  vpc_id = "${local.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
