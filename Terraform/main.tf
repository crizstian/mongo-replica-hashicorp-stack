provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

terraform {
  required_version = ">= 0.11.9"
}

module "aero_bastion_network" {
  source = "../modules/network/aero-bastion"

  bastion_cidr         = "${var.bastion_cidr}"
  bastion_private_cidr = "${var.bastion_private_cidr}"
  bastion_public_cidr  = "${var.bastion_public_cidr}"
  bastion_cluster_name = "${var.bastion_cluster_name}"

  available_zone = "${data.aws_availability_zones.available_zones.names[0]}"
}

module "aero_bastion_cluster" {
  source = "../modules/instance"

  ami_id        = "${data.aws_ami.proxy_image.id}"
  instance_type = "${var.proxy_instance_type}"
  subnet_id     = "${module.aero_bastion_network.bastion_public_subnet_id}"
  sg_ids        = ["${module.aero_bastion_network.bastion_sg_id}", "${module.aero_bastion_network.bastion_private_sg_id}"]
  ssh_key       = "${var.ssh_key_name}"
  user_data     = "${data.template_file.user_data_proxy.rendered}"
  cluster_name  = "${var.bastion_cluster_name}"
  volume_size   = 50
  instance_name = "BastionVM"
  associate_public_ip_address = true
}

resource "aws_instance" "mongo_vm" {
  count = 3
  ami                         = "${data.aws_ami.db_image.id}"
  instance_type               = "${var.db_instance_type}"
  subnet_id                   = "${aws_subnet.database_subnet.id}"
  vpc_security_group_ids      = ["${data.aws_security_groups.bastion_sg.ids[0]}"]
  key_name                    = "aero-cluster"
  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = 100
    delete_on_termination = true
  }
  user_data     = "${data.template_file.user_data_db.rendered}"
  tags {
    Name        = "${var.cluster_name}-MongoDB-Server"
    Environment = "${terraform.workspace}"
  }
}