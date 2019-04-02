variable "ami_id" {}
variable "num_of_instances" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "ssh_key" {}
variable "volume_size" {}
variable "user_data" {}
variable "cluster_name" {}
variable "instance_name" {}
variable "associate_public_ip_address" {}
variable "sg_ids" {
  type = "list"
}

resource "aws_instance" "vm" {
  count                       = "${var.num_of_instances}"
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${var.sg_ids}"]
  key_name                    = "${var.ssh_key}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = "${var.volume_size}"
    delete_on_termination = true
  }

  user_data = "${var.user_data}"

  tags {
    Name        = "${var.cluster_name}-${var.instance_name}"
    Environment = "${terraform.workspace}"
  }
}