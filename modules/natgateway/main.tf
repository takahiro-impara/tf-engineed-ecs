resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = var.public_subnet_id

  tags = var.tagNames
  depends_on = [
    aws_eip.this
  ]
}

resource "aws_eip" "this" {
  vpc = true
}

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id
  tags = {
    Name              = "private-routetable-${var.tagNames["Name"]}"
    aws-exam-resource = var.tagNames["aws-exam-resource"]
    state             = var.tagNames["state"]
  }
}

resource "aws_route" "this" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.this.id
  nat_gateway_id         = aws_nat_gateway.this.id

}

resource "aws_route_table_association" "private" {
  for_each       = toset(var.private_subnets)
  subnet_id      = each.key
  route_table_id = aws_route_table.this.id
}
