output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "bastion_subnet_id" {
  value = "${aws_subnet.bastion_subnet.id}"
}

output "server_subnet_id" {
  value = "${aws_subnet.instance_subnet.id}"
}
