locals {
  prefix = "demo"
  region = "ap-northeast-1"
  az_map = {
    "ap-northeast-1a" = 1,
    "ap-northeast-1c" = 2,
  }
  zone_name = "demo.h-arifuku.click"
  vpc_cidr  = "10.11.0.0/16"
  vpc_endpoint_services = [
    "ssm",
    "ssmmessages",
    "ec2messages",
    "secretsmanager",
  ]
  alb_listener_rule_path_patterns = ["/manage/*"]
  app = {
    default = {
      name                 = "contents-app"
      description          = "Contents Application Server"
      health_check_path    = "/"
      asg_desired_capacity = 2
      asg_min_size         = 2
      asg_max_size         = 8
      enable_scale_policy  = true
      ec2_ami_id           = "ami-06ee4e2261a4dc5c3"
      ec2_instance_type    = "t3.micro"
      ebs_device_name      = "/dev/sda1"
      ebs_type             = "gp3"
      ebs_size             = 20
      ebs_encryption       = true
      user_data            = file("contents.sh")
      allow_access_to = [
        "secretsmanager",
      ]
    },
    path_based = {
      name                 = "manage-app"
      description          = "Management Application Server"
      health_check_path    = "/manage/"
      asg_desired_capacity = 1
      asg_min_size         = 1
      asg_max_size         = 1
      enable_scale_policy  = false
      ec2_ami_id           = "ami-06ee4e2261a4dc5c3"
      ec2_instance_type    = "t3.micro"
      ebs_device_name      = "/dev/sda1"
      ebs_type             = "gp3"
      ebs_size             = 20
      ebs_encryption       = true
      user_data            = file("manage.sh")
      allow_access_to = [
        "s3",
        "secretsmanager",
      ]
    },
  }
  db_secret_id                     = "demo-db-secret"
  db_vertical_scale_min_capacity   = 0.5
  db_vertical_scale_max_capacity   = 10
  db_horizontal_scale_min_capacity = 1
  db_horizontal_scale_max_capacity = 15
  cache_node_type                  = "cache.t3.micro"
  cache_clusters_count             = 2
  waf_rule_names_and_priorities = {
    "AWSManagedRulesCommonRuleSet"          = 10,
    "AWSManagedRulesAdminProtectionRuleSet" = 20,
    "AWSManagedRulesKnownBadInputsRuleSet"  = 30,
    "AWSManagedRulesSQLiRuleSet"            = 40,
    "AWSManagedRulesLinuxRuleSet"           = 50,
    "AWSManagedRulesAmazonIpReputationList" = 60,
  }
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = local.db_secret_id
}

module "domain" {
  source       = "../../modules/domain"
  zone_name    = local.zone_name
  cdn_dns_name = module.edge.cdn_dns_name
  cdn_zone_id  = module.edge.cdn_zone_id
  alb_dns_name = module.alb.dns_name
  alb_zone_id  = module.alb.zone_id
}

module "edge" {
  source                = "../../modules/edge"
  prefix                = local.prefix
  root_domain           = local.zone_name
  cdn_cert_arn          = module.domain.cdn_cert_arn
  alb_id                = module.alb.id
  s3_bucket             = module.s3.static_bucket
  aws_managed_waf_rules = local.waf_rule_names_and_priorities
}

module "s3" {
  source = "../../modules/s3"
  prefix = local.prefix
}

module "network" {
  source       = "../../modules/network"
  prefix       = local.prefix
  vpc_cidr     = local.vpc_cidr
  region       = local.region
  az_map       = local.az_map
  vpce_service = local.vpc_endpoint_services
  apps = {
    "${local.app.default.name}" = {
      description = local.app.default.description
    },
    "${local.app.path_based.name}" = {
      description = local.app.path_based.description
    },
  }
}

module "alb" {
  source         = "../../modules/alb"
  prefix         = local.prefix
  alb_cert_arn   = module.domain.alb_cert_arn
  alb_subnet_ids = module.network.alb_subnet_ids
  alb_sg_ids     = module.network.alb_sg_ids
  vpc_id         = module.network.vpc_id
  alb_tg = {
    "${local.app.default.name}" = {
      health_check_path = local.app.default.health_check_path
    },
    "${local.app.path_based.name}" = {
      health_check_path = local.app.path_based.health_check_path
    },
  }
  default_app_name    = local.app.default.name
  path_based_app_name = local.app.path_based.name
  rule_path_patterns  = local.alb_listener_rule_path_patterns
}

module "iam_role" {
  source            = "../../modules/iam_role"
  prefix            = local.prefix
  static_bucket_arn = module.s3.static_bucket.arn
  db_secret_arn     = data.aws_secretsmanager_secret_version.db.arn
  apps = {
    "${local.app.default.name}" = {
      allow_access_to = local.app.default.allow_access_to
    },
    "${local.app.path_based.name}" = {
      allow_access_to = local.app.path_based.allow_access_to
    },
  }
}

module "autoscaling" {
  source         = "../../modules/autoscaling"
  prefix         = local.prefix
  asg_subnet_ids = module.network.app_subnet_ids
  asg = {
    "${local.app.default.name}" = {
      sg_ids              = [module.network.app_sg["${local.app.default.name}"].id]
      role_name           = module.iam_role.app["${local.app.default.name}"].name
      target_group_arns   = [module.alb.tg["${local.app.default.name}"].arn]
      desired_capacity    = local.app.default.asg_desired_capacity
      min_size            = local.app.default.asg_min_size
      max_size            = local.app.default.asg_max_size
      enable_scale_policy = local.app.default.enable_scale_policy
      image_id            = local.app.default.ec2_ami_id
      instance_type       = local.app.default.ec2_instance_type
      device_name         = local.app.default.ebs_device_name
      volume_type         = local.app.default.ebs_type
      volume_size         = local.app.default.ebs_size
      volume_encrypted    = local.app.default.ebs_encryption
      user_data           = local.app.default.user_data
    },
    "${local.app.path_based.name}" = {
      sg_ids              = [module.network.app_sg["${local.app.path_based.name}"].id]
      role_name           = module.iam_role.app["${local.app.path_based.name}"].name
      target_group_arns   = [module.alb.tg["${local.app.path_based.name}"].arn]
      desired_capacity    = local.app.path_based.asg_desired_capacity
      min_size            = local.app.path_based.asg_min_size
      max_size            = local.app.path_based.asg_max_size
      enable_scale_policy = local.app.path_based.enable_scale_policy
      image_id            = local.app.path_based.ec2_ami_id
      instance_type       = local.app.path_based.ec2_instance_type
      device_name         = local.app.path_based.ebs_device_name
      volume_type         = local.app.path_based.ebs_type
      volume_size         = local.app.path_based.ebs_size
      volume_encrypted    = local.app.path_based.ebs_encryption
      user_data           = local.app.path_based.user_data
    },
  }
}

module "db" {
  source     = "../../modules/db"
  prefix     = local.prefix
  az         = keys(local.az_map)
  subnet_ids = module.network.db_subnet_ids
  sg_ids     = module.network.db_sg_ids
  master_username = jsondecode(
    data.aws_secretsmanager_secret_version.db.secret_string
  ).username
  master_password = jsondecode(
    data.aws_secretsmanager_secret_version.db.secret_string
  ).password
  serverlessv2_min_capacity  = local.db_vertical_scale_min_capacity
  serverlessv2_max_capacity  = local.db_vertical_scale_max_capacity
  replica_scale_min_capacity = local.db_horizontal_scale_min_capacity
  replica_scale_max_capacity = local.db_horizontal_scale_max_capacity
}

module "cache" {
  source           = "../../modules/cache"
  prefix           = local.prefix
  cache_subnet_ids = module.network.cache_subnet_ids
  cache_sg_ids     = module.network.cache_sg_ids
  node_type        = local.cache_node_type
  clusters_count   = local.cache_clusters_count
}
