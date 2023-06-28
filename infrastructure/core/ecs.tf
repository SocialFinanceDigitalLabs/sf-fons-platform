resource "aws_ecs_cluster" "sfdata-ecs-cluster" {
  name = "${var.platform_name}-ecs-cluster"
}