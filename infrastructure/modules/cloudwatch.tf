resource "aws_cloudwatch_log_group" "dagster" {
  name              = "${var.platform_name}-dagster"
  retention_in_days = var.log_retention
}