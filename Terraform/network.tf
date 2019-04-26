resource "aws_subnet" "database_subnet" {
  cidr_block        = var.database_private_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  vpc_id            = module.aero_bastion_network.bastion_vpc_id

  tags = {
    Application = var.cluster_name
    Environment = terraform.workspace
    Name        = "${var.cluster_name}-database-subnet"
  }
}

resource "aws_route_table_association" "associate_database_subnet" {
  route_table_id = module.aero_bastion_network.bastion_private_route_table_id
  subnet_id      = aws_subnet.database_subnet.id
}

