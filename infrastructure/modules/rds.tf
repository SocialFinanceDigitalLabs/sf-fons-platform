resource "aws_rds_cluster" "dagster" {
  cluster_identifier = "${var.platform_name}-aurora-cluster"
  engine             = "aurora-postgresql"
  availability_zones = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c",
  ]
  database_name           = "platformdb"
  master_username         = random_string.db_user
  master_password         = random_password.db_master
  backup_retention_period = 5
  preferred_backup_window = "23:00-00:00"
}