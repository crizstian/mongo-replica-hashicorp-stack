data "aws_availability_zones" "available_zones" {}

data "aws_ami" "db_image" {
  most_recent = true
  owners      = ["${var.aws_account}"]

  filter {
    name   = "name"
    values = ["mongo*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "proxy_image" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20190212"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "user_data_db" {
  template = "${file("${path.module}/bin/user-data-db.sh")}"

  vars {
    dbAdminUser        = "${var.dbUser}"
    dbAdminUserPass    = "${var.dbUserPass}"
    dbReplicaAdmin     = "${var.dbReplicaAdmin}"
    dbReplicaAdminPass = "${var.dbReplicaAdminPass}"
    dbReplSetName      = "${var.dbReplSetName}"

    access_key         = "${var.access_key}"
    secret_key         = "${var.secret_key}"
    region             = "${var.region}"
  }
}