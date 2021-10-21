terraform {
  required_version = "~> 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "remote" {
    organization = "impara8"

    workspaces {
      name = "tf-engineed-ecs"
    }
  }
}

locals {
  env    = "develop"
  region = "ap-northeast-1"
  tagNames = {
    "aws-exam-resource" : true,
    "Name" : "eng-exam-container",
    "state" : local.env
  }
  vpc_cidr = "10.18.0.0/16"
  public_subnets = {
    "az-a" : {
      "cidr" : "10.18.0.0/24",
      "az" : "ap-northeast-1a"
    },
    "az-c" : {
      "cidr" : "10.18.1.0/24",
      "az" : "ap-northeast-1c"
    },
  }
  private_subnets = {
    "az-a" : {
      "cidr" : "10.18.10.0/24",
      "az" : "ap-northeast-1a"
    },
    "az-c" : {
      "cidr" : "10.18.11.0/24",
      "az" : "ap-northeast-1c"
    },
  }
  secure_subets = {
    "az-a" : {
      "cidr" : "10.18.20.0/24",
      "az" : "ap-northeast-1a"
    },
    "az-c" : {
      "cidr" : "10.18.21.0/24",
      "az" : "ap-northeast-1c"
    },
  }

  domain = "00122.engineed-exam.com"

  instance_class = "db.t3.small"
  node_type      = "cache.t2.micro"
}
provider "aws" {
  region = local.region
  assume_role {
    role_arn = var.assume_role
  }
}

provider "aws" {
  alias  = "us_region"
  region = "us-east-1"
  assume_role {
    role_arn = var.assume_role
  }
}

module "vpc" {
  source          = "app.terraform.io/impara8/private-vpc/aws"
  version         = "1.0.0"
  vpc_cidr        = local.vpc_cidr
  tagNames        = local.tagNames
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
  secure_subets   = local.secure_subets
}

module "s3" {
  source      = "../../modules/s3/"
  tagNames    = local.tagNames
  env         = local.env
  acl         = "public-read"
  policy      = "../../policies/s3.json"
  assume_role = var.assume_role
}

module "rds" {
  source         = "../../modules/rds/"
  tagNames       = local.tagNames
  subnets        = module.vpc.secure_ids
  instance_class = local.instance_class
  username       = var.username
  password       = var.password
  vpc_security_group_ids = [
    module.sg-dev-sql-3306.sec_group.id,
  ]
}

module "redis-cluster" {
  source                = "../../modules/elasticache/"
  tagNames              = local.tagNames
  availability_zones    = ["ap-northeast-1a"]
  node_type             = local.node_type
  number_cache_clusters = 1
  security_group_ids = [
    module.sg-dev-redis-6379.sec_group.id,
  ]
  subnets = module.vpc.secure_ids
}

module "ecr-nginx" {
  source   = "../../modules/ecr/"
  name     = "nginx"
  tagNames = local.tagNames
}

module "ecr-php" {
  source   = "../../modules/ecr/"
  name     = "php"
  tagNames = local.tagNames
}

module "ecs-cluster" {
  source   = "../../modules/ecs/cluster/"
  name     = local.tagNames["Name"]
  tagNames = local.tagNames
}

module "ecs-task-nginx" {
  source             = "../../modules/ecs/task_definition/"
  name               = "nginx-new"
  tagNames           = local.tagNames
  execution_role_arn = "arn:aws:iam::974783918237:role/ecsTaskExecutionRole"
  containerPort      = 80
  hostPort           = 80
  image              = "974783918237.dkr.ecr.ap-northeast-1.amazonaws.com/nginx:latest"
  cpu                = 512
  memory             = 1024
  task_role_arn      = "arn:aws:iam::974783918237:role/ECSTaskRole"
}
module "ecs-task-php" {
  source             = "../../modules/ecs/task_definition/"
  name               = "php-new"
  tagNames           = local.tagNames
  execution_role_arn = "arn:aws:iam::974783918237:role/ecsTaskExecutionRole"
  containerPort      = 9000
  hostPort           = 9000
  image              = "974783918237.dkr.ecr.ap-northeast-1.amazonaws.com/php:latest"
  cpu                = 512
  memory             = 1024
  task_role_arn      = "arn:aws:iam::974783918237:role/ECSTaskRole"
}

module "ecs-service-alb" {
  source           = "../../modules/ecs/service/alb/"
  tagNames         = local.tagNames
  cluster          = module.ecs-cluster.aws_ecs_cluster.id
  task_definition  = module.ecs-task-nginx.aws_ecs_task_definition_arn
  desired_count    = 1
  target_group_arn = module.alb.aws_lb_target_group.arn
  container_name   = "nginx-new"
  container_port   = 80
  subnets          = module.vpc.private_ids
  security_groups = [
    module.sg-http-80.sec_group.id,
    module.sg-internal-all.sec_group.id,
  ]
  name             = "nginx-new"
  listener_arn     = module.alb.aws_lb_listener_arn
  assign_public_ip = false
}

module "ecs-service-php" {
  source          = "../../modules/ecs/service/service-registry/"
  tagNames        = local.tagNames
  cluster         = module.ecs-cluster.aws_ecs_cluster.id
  task_definition = module.ecs-task-php.aws_ecs_task_definition_arn
  desired_count   = 1
  container_name  = "php-new"
  container_port  = 9000
  subnets         = module.vpc.private_ids
  security_groups = [
    module.sg-php-9000.sec_group.id,
    module.sg-internal-all.sec_group.id,

  ]
  name             = "php-new"
  vpc_id           = module.vpc.vpc_id
  assign_public_ip = false
}
module "alb" {
  source   = "../../modules/elb"
  name     = local.tagNames["Name"]
  tagNames = local.tagNames
  subnets  = module.vpc.public_ids
  securitygroups = [
    module.sg-https-443.sec_group.id,
    module.sg-http-80.sec_group.id,
  ]
  vpc_id     = module.vpc.vpc_id
  targetname = "nginx"
}

module "acm" {
  source = "../../modules/acm/"
  providers = {
    aws = aws.us_region
  }
  domain   = local.domain
  tagNames = local.tagNames
}

module "waf" {
  source   = "../../modules/waf/"
  tagNames = local.tagNames
  providers = {
    aws = aws.us_region
  }
}

module "cw-metric-filter" {
  source         = "../../modules/cloudwatch/metric_filter/"
  name           = "/ecs/php-new"
  pattern        = "500"
  log_group_name = "/ecs/php-new"
  depends_on = [
    module.ecs-task-php
  ]
}
module "cloudfront" {
  source = "../../modules/cloudfront/"

  tagNames            = local.tagNames
  alb_domain_name     = module.alb.alb_dns_name
  acm_certificate_arn = module.acm.aws_acm_certificate.arn
  domain              = local.domain
  web_acl_id          = module.waf.aws_wafv2_web_acl.arn
}

module "route53" {
  source                      = "../../modules/route53/"
  domain                      = local.domain
  aws_acm_certificate         = module.acm.aws_acm_certificate
  aws_cloudfront_distribution = module.cloudfront.aws_cloudfront_distribution
}
#iam
module "iam-ecs-ssm" {
  source = "../../modules/iam/ecs-ssm/"
}


module "codecommit" {
  source          = "../../modules/codecommit/"
  repository_name = "eventnow"
  tagNames        = local.tagNames
}

module "s3endpoint" {
  source   = "../../modules/endpoint/"
  tagNames = local.tagNames
  vpc_id   = module.vpc.vpc_id
}

module "natgw" {
  source           = "../../modules/natgateway/"
  tagNames         = local.tagNames
  public_subnet_id = module.vpc.public_ids.0
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_ids
}
#sg
module "sg-dev-sql-3306" {
  source      = "app.terraform.io/impara8/private-securitygroup/aws"
  version     = "1.0.0"
  name        = "db_sec_group_dev_3306"
  tagNames    = local.tagNames
  server_port = 3306
  cidr_blocks = ["10.18.0.0/16"]
  protocol    = "tcp"
  vpc_id      = module.vpc.vpc_id
}

module "sg-dev-redis-6379" {
  source      = "app.terraform.io/impara8/private-securitygroup/aws"
  version     = "1.0.0"
  name        = "redis_sec_group_dev_6379"
  tagNames    = local.tagNames
  server_port = 6379
  cidr_blocks = ["10.18.0.0/16"]
  protocol    = "tcp"
  vpc_id      = module.vpc.vpc_id
}

module "sg-https-443" {
  source      = "app.terraform.io/impara8/private-securitygroup/aws"
  version     = "1.0.0"
  name        = "https_443"
  tagNames    = local.tagNames
  server_port = 443
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "tcp"
  vpc_id      = module.vpc.vpc_id
}
module "sg-http-80" {
  source      = "app.terraform.io/impara8/private-securitygroup/aws"
  version     = "1.0.0"
  name        = "http_80"
  tagNames    = local.tagNames
  server_port = 80
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "tcp"
  vpc_id      = module.vpc.vpc_id
}
module "sg-php-9000" {
  source      = "app.terraform.io/impara8/private-securitygroup/aws"
  version     = "1.0.0"
  name        = "php_9000"
  tagNames    = local.tagNames
  server_port = 9000
  cidr_blocks = ["10.18.0.0/16"]
  protocol    = "tcp"
  vpc_id      = module.vpc.vpc_id
}

module "sg-internal-all" {
  source      = "app.terraform.io/impara8/private-securitygroup/aws"
  version     = "1.0.0"
  name        = "internal_all"
  tagNames    = local.tagNames
  server_port = 0
  cidr_blocks = ["10.18.0.0/16"]
  protocol    = -1
  vpc_id      = module.vpc.vpc_id
}
