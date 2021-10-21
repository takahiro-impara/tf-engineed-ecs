resource "aws_rds_cluster" "example" {
  cluster_identifier              = var.tagNames["Name"]
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.mysql_aurora.2.09.2"
  master_username                 = var.username
  master_password                 = var.password
  port                            = 3306
  vpc_security_group_ids          = var.vpc_security_group_ids
  db_subnet_group_name            = aws_db_subnet_group.this.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  skip_final_snapshot = true
  apply_immediately   = true
  tags                = var.tagNames
}

resource "aws_db_subnet_group" "this" {
  name       = var.tagNames["Name"]
  tags       = var.tagNames
  subnet_ids = var.subnets

}
resource "aws_rds_cluster_parameter_group" "this" {
  name   = var.tagNames["Name"]
  family = "aurora-mysql5.7"

  parameter {
    name         = "character_set_client"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_connection"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_database"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_filesystem"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_results"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_server"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_connection"
    value        = "utf8mb4_general_ci"
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_server"
    value        = "utf8mb4_general_ci"
    apply_method = "immediate"
  }

  parameter {
    name         = "time_zone"
    value        = "Asia/Tokyo"
    apply_method = "immediate"
  }
}

resource "aws_rds_cluster_instance" "example" {
  count = 2

  cluster_identifier = aws_rds_cluster.example.id
  identifier         = "${var.tagNames["Name"]}-instance-${count.index}"

  engine                  = aws_rds_cluster.example.engine
  engine_version          = aws_rds_cluster.example.engine_version
  instance_class          = var.instance_class
  db_subnet_group_name    = aws_db_subnet_group.this.name
  db_parameter_group_name = aws_db_parameter_group.example.name

  #monitoring_role_arn = aws_iam_role.aurora_monitoring.arn
  #monitoring_interval = 60

  publicly_accessible = true
  tags                = var.tagNames
}

resource "aws_db_parameter_group" "example" {
  name   = var.tagNames["Name"]
  family = "aurora-mysql5.7"
}
