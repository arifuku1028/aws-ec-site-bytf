resource "aws_rds_cluster" "aurora_mysql_v2" {
  cluster_identifier     = "${var.prefix}-aurora-mysql-serverless-v2"
  engine                 = "aurora-mysql"
  engine_mode            = "provisioned"
  engine_version         = var.engine_version
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = var.sg_ids
  master_username        = var.master_username
  master_password        = var.master_password
  port                   = 3306
  storage_encrypted      = true
  serverlessv2_scaling_configuration {
    max_capacity = var.serverlessv2_max_capacity
    min_capacity = var.serverlessv2_min_capacity
  }
}

resource "aws_rds_cluster_instance" "aurora_mysql_v2" {
  count              = 2
  cluster_identifier = aws_rds_cluster.aurora_mysql_v2.id
  availability_zone  = var.az[count.index % length(var.az)]
  identifier         = "${aws_rds_cluster.aurora_mysql_v2.id}-instance-${count.index}"
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora_mysql_v2.engine
  engine_version     = aws_rds_cluster.aurora_mysql_v2.engine_version
}

resource "aws_db_subnet_group" "db" {
  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags = {
    Name = "${var.prefix}-db-subnet-group"
  }
}

resource "aws_db_parameter_group" "aurora_mysql8" {
  name        = "${var.prefix}-aurora-mysql8-db-parameter-group"
  family      = "aurora-mysql8.0"
  description = "DB Parameter Group for Aurora MySQL8"
}

resource "aws_rds_cluster_parameter_group" "example_mysql8" {
  name        = "${var.prefix}-aurora-mysql8-cluster-parameter-group"
  family      = "aurora-mysql8.0"
  description = "Cluster Parameter Group for Aurora MySQL8"
}

resource "aws_appautoscaling_target" "aurora_replica" {
  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.aurora_mysql_v2.id}"
  min_capacity       = var.replica_scale_min_capacity
  max_capacity       = var.replica_scale_max_capacity
}

resource "aws_appautoscaling_policy" "aurora_replica" {
  name               = "${var.prefix}-aurora-replica-scale-policy"
  service_namespace  = aws_appautoscaling_target.aurora_replica.service_namespace
  scalable_dimension = aws_appautoscaling_target.aurora_replica.scalable_dimension
  resource_id        = aws_appautoscaling_target.aurora_replica.resource_id
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }
    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
