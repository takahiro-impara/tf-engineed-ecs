
resource "aws_elasticache_subnet_group" "this" {
  name       = "tf-subnet-${var.tagNames["Name"]}"
  subnet_ids = var.subnets
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = "cluster-rep-group-${var.tagNames["Name"]}"
  replication_group_description = "cluster-rep-group-${var.tagNames["Name"]}"
  engine                        = "redis"
  node_type                     = var.node_type
  number_cache_clusters         = var.number_cache_clusters
  automatic_failover_enabled    = true
  engine_version                = "5.0.6"
  parameter_group_name          = "default.redis5.0"
  port                          = 6379
  tags                          = var.tagNames
  security_group_ids            = var.security_group_ids
  subnet_group_name             = aws_elasticache_subnet_group.this.name
}
