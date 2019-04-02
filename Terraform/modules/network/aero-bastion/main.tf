resource "null_resource" "vpc_ready" {
    depends_on = [ 
        "aws_nat_gateway.nat_gateway", 
        "aws_route.route_to_nat"
    ]
}
