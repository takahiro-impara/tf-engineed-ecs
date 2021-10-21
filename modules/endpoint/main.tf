data "aws_route_tables" "rts" {
  vpc_id = var.vpc_id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.ap-northeast-1.s3"
  route_table_ids = data.aws_route_tables.rts.ids
  tags            = var.tagNames
}
