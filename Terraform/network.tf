resource "aws_subnet" "database_subnet" {
  cidr_block        = "${var.database_private_cidr}"
  availability_zone = "${data.aws_availability_zones.available_zones.names[0]}"
  vpc_id            = "${data.aws_vpcs.cluster_vpcs.ids[0]}"

  tags {
    Application = "${var.cluster_name}"
    Environment = "${terraform.workspace}"
    Name        = "${var.cluster_name}-database-subnet"
  }
}

resource "aws_route_table" "database_route_table" {
  vpc_id = "${data.aws_vpcs.cluster_vpcs.ids[0]}"

  tags {
    Application = "${var.cluster_name}"
    Environment = "${terraform.workspace}"
    Name        = "${var.cluster_name}-database-route-table"
  }
}

resource "aws_route_table_association" "associate_database_subnet" {
  route_table_id = "${aws_route_table.database_route_table.id}"
  subnet_id      = "${aws_subnet.database_subnet.id}"
}


resource "aws_route" "route_to_nat" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${data.aws_nat_gateway.bastion_ngw.id}"
  route_table_id         = "${aws_route_table.database_route_table.id}"
}