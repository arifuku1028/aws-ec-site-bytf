resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.prefix}-redis"
  description                = "ElastiCache for Redis"
  engine                     = "redis"
  engine_version             = "5.0.6"
  port                       = 6379
  node_type                  = var.node_type
  num_cache_clusters         = var.clusters_count
  subnet_group_name          = aws_elasticache_subnet_group.cache.name
  security_group_ids         = var.cache_sg_ids
  multi_az_enabled           = true
  automatic_failover_enabled = true
}

resource "aws_elasticache_subnet_group" "cache" {
  name       = "${var.prefix}-cache-subnet-group"
  subnet_ids = var.cache_subnet_ids
}
