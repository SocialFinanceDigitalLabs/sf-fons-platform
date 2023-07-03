resource "aws_ecs_service" "platform-service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.sfdata-ecs-service.arn
  launch_type     = "FARGATE"
  desired_count   = 3

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.sfdata-ecs-service.family
    container_port   = 3000
  }

  network_configuration {
    subnets = [
      aws_subnet.public-subnet-1,
      aws_subnet.public-subnet-2
    ]
    assign_public_ip = true
    security_groups = [
      aws_security_group.allow_tls.id
    ]
  }
}

resource "aws_ecs_cluster_capacity_providers" "platform" {
  cluster_name = aws_ecs_cluster.ecs-cluster.name

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }

}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.platform_name}-ecs-cluster"
}

resource "aws_ecs_task_definition" "sfdata-ecs-service" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "dagit"
      image     = aws_ecr_repository.dagit.repository_url
      cpu       = 2
      memory    = 128
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        { name : "DAGSTER_POSGRES_HOST", value : aws_rds_cluster.dagster.endpoint },
        { name : "DAGSTER_POSTGRES_USER", value : random_string.db_user },
        { name : "DAGSTER_POSTGRES_PASSWORD", value : random_password.db_master },
        { name : "DAGSTER_POSTGRES_DB", value : aws_rds_cluster.dagster.database_name }
      ]
      entryPoint = [
        "sh", "-c"
      ]
      command = [
        "dagit",
        "-h",
        "0.0.0.0",
        "-p",
        "3000",
        "-w",
        "workspace.yaml"
      ]
    },
    {
      name      = "daemon"
      image     = "service-second"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
      entryPoint = [
        "sh", "-c"
      ]
      command = [
        "dagster-daemon", "run"
      ]
      environment = [
        { name : "DAGSTER_POSGRES_HOST", value : aws_rds_cluster.dagster.endpoint },
        { name : "DAGSTER_POSTGRES_USER", value : random_string.db_user },
        { name : "DAGSTER_POSTGRES_PASSWORD", value : random_password.db_master },
        { name : "DAGSTER_POSTGRES_DB", value : aws_rds_cluster.dagster.database_name }
      ]
    },
    {
      name      = "code_server"
      image     = "service-second"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
      environment = [
        { name : "DAGSTER_POSGRES_HOST", value : aws_rds_cluster.dagster.endpoint },
        { name : "DAGSTER_POSTGRES_USER", value : random_string.db_user },
        { name : "DAGSTER_POSTGRES_PASSWORD", value : random_password.db_master },
        { name : "DAGSTER_POSTGRES_DB", value : aws_rds_cluster.dagster.database_name },
        { name : "CODE_FOLDER", value : "" },
        { name : "REPO_LOCATION", value : "" }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}