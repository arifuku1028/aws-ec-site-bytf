output "cluster_endpoint" {
  value = aws_rds_cluster.aurora_mysql_v2.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.aurora_mysql_v2.reader_endpoint
}
