locals {

  application_name = "document-handler"
  document-handler_backend_image_url = aws_ecr_repository.document-handler-ecr.repository_url

  container_http_port = 8080
  host_http_port = 8080
}

resource aws_ecs_cluster "vscan-api-ecs-cluster" {
  name = "vscan-api-cluster"
  tags = local.tags
}

resource "aws_cloudwatch_log_group" "document-handler-backend-log-group" {
  name = local.application_name
  retention_in_days = "7"
}

resource "aws_ecs_task_definition" "document-handler-task-def" {
  family = "document-handler-service"

  cpu    = "1024"
  memory = "2048"
  requires_compatibilities = ["FARGATE"]

  container_definitions = <<TASK_DEFINITION
[
  {
    "environment": [
      {"name": "SPRING_APPLICATION_NAME", "value": "${local.application_name}"},
      {"name": "SPRING_PROFILES_ACTIVE", "value": "${terraform.workspace}"},
      {"name": "JAVA_TOOL_OPTIONS", "value": "-XX:MaxRAMPercentage=70"}
    ],
    "essential": true,
    "image": "${local.document-handler_backend_image_url}:latest",
    "name": "document-handler",
    "memoryReservation": 2048,
    "portMappings": [
      {
        "containerPort": ${local.container_http_port},
        "hostPort": ${local.host_http_port}
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.document-handler-backend-log-group.name}",
            "awslogs-region": "${local.region}",
            "awslogs-stream-prefix": "document-handler"
        }
    }
  }
]
TASK_DEFINITION

  task_role_arn = aws_iam_role.document-handler-ecs-task-role.arn
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  network_mode = "awsvpc"
  tags = local.tags

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_security_group" "document-handler-security-group" {
  name = "document-handler-sg"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "document-handler_sg_egress_rule" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.document-handler-security-group.id
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}

resource "aws_ecs_service" "document-handler-backend-service" {
  name = local.application_name

  cluster         = aws_ecs_cluster.vscan-api-ecs-cluster.id
  task_definition = aws_ecs_task_definition.document-handler-task-def.arn
  desired_count   = 1

  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100

  launch_type = "FARGATE"

  deployment_circuit_breaker {
    enable=true
    rollback=true
  }

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [aws_security_group.document-handler-security-group.id]
  }


  lifecycle {
    ignore_changes = [task_definition]
  }
}