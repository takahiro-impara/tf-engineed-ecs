
resource "aws_elasticache_subnet_group" "this" {
  name       = "tf-subnet-${var.tagNames["Name"]}"
  subnet_ids = var.subnets
}

resource "aws_elasticache_cluster" "this" {
  cluster_id           = "tf-rep-group-${var.tagNames["Name"]}"
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.number_cache_clusters
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379
  tags                 = var.tagNames
  security_group_ids   = var.security_group_ids
  subnet_group_name    = aws_elasticache_subnet_group.this.name
}
