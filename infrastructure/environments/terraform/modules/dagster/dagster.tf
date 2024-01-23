resource "aws_kms_key" "db_password" {
  description = "Database KMS Key"
}

resource "random_password" "master"{
  length           = 20
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "test-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.master.result
}

resource "aws_logs_log_group" "dagit_log_group" {
  name              = "${var.project_name}-${var.organisation_name}-Dagit-LogGroup-${var.environment}"
  retention_in_days = 7
}

resource "aws_logs_log_group" "code_server_log_group" {
  name              = "${var.project_name}-${var.organisation_name}-CodeServer-LogGroup-${var.environment}"
  retention_in_days = 7
}

resource "aws_logs_log_group" "daemon_log_group" {
  name              = "${var.project_name}-${var.organisation_name}-Daemon-LogGroup-${var.environment}"
  retention_in_days = 7
}

resource "aws_iam_role" "dagit_task_execution_role" {
  name = "DagitTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
      },
    ],
  })

  policies = [
    {
      name = "DagitTaskExecutionSSM",
      policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Effect = "Allow",
            Action = [
              "ssm:GetParameters",
              "secretsmanager:GetSecretValue",
            ],
            Resource = [
              "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:task/*/*",
              "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/CodeServerTask:*",
            ],
          },
          {
            Effect = "Allow",
            Action = [
              "ecs:DescribeTaskDefinition",
            ],
            Resource = ["*"],
          },
        ],
      }),
    },
  ]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
}

resource "aws_iam_role" "dagit_task_role" {
  name = "DagitTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
      },
    ],
  })

  policies = [
    {
      name = "DagitTaskHandling",
      policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Effect = "Allow",
            Action = [
              "ecs:RunTask",
              "ecs:StartTask",
              "ecs:StopTask",
              "ecs:DescribeTasks",
              "ecs:DescribeTaskDefinition",
            ],
            Resource = [
              "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:task/*/*",
              "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/CodeServerTask:*",
            ],
          },
          {
            Effect = "Allow",
            Action = [
              "ecs:DescribeTaskDefinition",
            ],
            Resource = ["*"],
          },
        ],
      }),
    },
  ]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
}

resource "aws_iam_role" "daemon_task_execution_role" {
  name = "DaemonTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
      },
    ],
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
}

resource "aws_iam_role" "daemon_task_role" {
  name = "DaemonTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
      },
    ],
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
}

resource "aws_iam_role" "code_server_task_execution_role" {
  name = "CodeServerTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
      },
    ],
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
}

resource "aws_iam_role" "code_server_task_role" {
  name = "${var.project_name}-CodeServerTaskRole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "code_server_task_handling_policy" {
  name        = "${var.project_name}-CodeServerTaskHandlingPolicy"
  description = "Policy for handling Code Server tasks"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask",
        "ecs:StartTask",
        "ecs:StopTask",
        "ecs:DescribeTasks",
        "ecs:DescribeTaskDefinition"
      ],
      "Resource": [
        "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:task/*/*",
        "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/CodeServerTask:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeTaskDefinition"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "code_server_task_handling_attachment" {
  policy_arn = aws_iam_policy.code_server_task_handling_policy.arn
  role       = aws_iam_role.code_server_task_role.name
}

resource "aws_iam_role_policy_attachment" "code_server_task_execution_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.code_server_task_role.name
}

resource "aws_iam_role_policy_attachment" "code_server_cloudwatch_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.code_server_task_role.name
}

resource "aws_iam_role_policy_attachment" "code_server_ecr_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly"
  role       = aws_iam_role.code_server_task_role.name
}

resource "aws_iam_role_policy_attachment" "code_server_ec2cr_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.code_server_task_role.name
}

resource "aws_ecs_task_definition" "code_server_task_definition" {
  family                   = "CodeServerTask"
  execution_role_arn       = aws_iam_role.code_server_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu           = "256"
  memory        = "1024"
  task_role_arn = aws_iam_role.code_server_task_role.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "user_code",
    "image": "${var.user_code1_image_path}",
    "memory": 512,
    "portMappings": [
      {
        "containerPort": 4000,
        "protocol": "tcp",
        "name": "4000"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.code_server_log_group.name}",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-create-group": "true",
        "awslogs-stream-prefix": "dagster-user-code"
      }
    },
    "environment": [
      {
        "name": "CODE_FOLDER",
        "value": "${var.code_server_pipeline_folder}"
      },
      {
        "name": "REPO_LOCATION",
        "value": "${var.code_server_pipeline_repo_location}"
      },
      {
        "name": "OUTPUT_LOCATION",
        "value": "${var.output_location}"
      },
      {
        "name": "INCOMING_LOCATION",
        "value": "${var.input_location}"
      },
      {
        "name": "DAGSTER_POSTGRES_HOST",
        "value": "${aws_rds_cluster.dagster_database_cluster.}"
      },
      {
        "name": "DAGSTER_POSTGRES_USER",
        "value": "${var.db_username}"
      },
      {
        "name": "DAGSTER_POSTGRES_PASSWORD",
        "value": "${aws_secretsmanager_secret_version.db_password.secret_string}"
      },
      {
        "name": "DAGSTER_POSTGRES_DB",
        "value": "${var.db_name}"
      },
      {
        "name": "DAGSTER_POSTGRES_PORT",
        "value": "${var.db_port}"
      }
    ]
  }
]
DEFINITION
}

resource "aws_cloudwatch_log_group" "code_server_log_group" {
  name              = "${var.project_name}-${var.organisation_name}-CodeServer-LogGroup-${var.environment}"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "dagster_cluster" {
  name = "DagsterCluster"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_ecs_service" "code_server_service" {
  name            = "CodeServerService"
  cluster         = aws_ecs_cluster.dagster_cluster.id
  task_definition = aws_ecs_task_definition.code_server_task_definition.family
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
    security_groups = [aws_security_group.code_server_security_group.id]
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.private_service_discovery_namespace
    service {
      client_alias {
        discovery_name = "user_code"
        port_name = "4000"
        client_alias {
          dns_name = "user_code"
          port = 4000
        }
      }
    }
    log_configuration {
      log_driver = "awslogs"
      options {
        awslogs-group = "dagster-daemon-code-service-map"
        awslogs-region = data.aws_region.current
        awslogs-create-group = true
        awslogs-stream-prefix = "dagster"
      }
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_servicediscovery_private_dns_namespace" "private_dns_namespace" {
  name        = var.private_service_discovery_namespace
  description = "Namespace for private network."
}

/*resource "aws_service_discovery_service" "user_code_service" {
  name         = "user_code"

  dns_config {
    namespace_id = aws_servicediscovery_private_dns_namespace.private_dns_namespace.id
    dns_records {
      ttl = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_config {
    failure_threshold = 10
    resource_path     = "path"
    type              = "HTTP"
  }
}*/

/*resource "aws_ecs_service_discovery" "user_code_service_discovery" {
  service_id      = aws_service_discovery_service.user_code_service.id
  container_name  = "user_code"
  container_port  = 4000
  dns_record_type = "A"
}*/

// Define other resources like AWS VPC, Subnets, Security Groups, etc., as needed.


resource "aws_rds_cluster" "dagster_database_cluster" {
  cluster_identifier      = var.db_name
  engine                  = var.db_engine
  engine_mode = serverless
  availability_zones      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  database_name           = var.db_name
  master_username         = var.db_username
  manage_master_user_password = true
  master_user_secret_kms_key_id = aws_kms_key.db_password.key_id
  backup_retention_period = 5
  preferred_backup_window = "04:00-06:00"
  storage_encrypted = true

  serverlessv2_scaling_configuration {
    max_capacity = var.db_max_capacity
    min_capacity = var.db_min_capacity
  }

  vpc_security_group_ids = [
    aws_security_group.database_security_group.id
  ]

  db_subnet_group_name = aws_db_subnet_group.database_subnet_group.name
}


data "aws_caller_identity" "current" {}

data "aws_region" "current" {}