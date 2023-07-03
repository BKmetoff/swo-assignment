locals {
  repo_address  = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  image_address = "${local.repo_address}/${var.container_specs.image.name}:${var.container_specs.image.tag}"
}

resource "aws_ecs_cluster" "cluster" {
  name = var.container_specs.image.name
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

# The below role is used to combine policies for:
# ECS task execution,
# ECS autoscaling,
# RDS access
resource "aws_iam_role" "ecs_rds_access_role" {
  name               = "GivesECSAccessToRDS"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# https://stackoverflow.com/questions/45486041/how-to-attach-multiple-iam-policies-to-iam-roles-using-terraform
resource "aws_iam_policy_attachment" "ecs_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ])

  name  = "AttachesRDSFullAccess"
  roles = [aws_iam_role.ecs_rds_access_role.name, "ecsTaskExecutionRole"]
  # policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  policy_arn = each.value
}


resource "aws_ecs_task_definition" "task" {
  family                   = var.container_specs.image.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_specs.resources.cpu
  memory                   = var.container_specs.resources.memory
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_rds_access_role.arn
  # execution_role_arn       = aws_iam_role.ecs_rds_access_role.arn

  volume {
    name = "${var.name}-efs-volume"
    efs_volume_configuration {
      file_system_id     = var.efs_system_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        iam = "ENABLED"
      }
    }
  }

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/taskdef-envfiles.html
  container_definitions = <<DEFINITION
[
  {
    "image": "${local.image_address}",
    "cpu": ${var.container_specs.resources.cpu},
    "memory": ${var.container_specs.resources.memory},
    "name": "${var.container_specs.image.name}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.container_specs.port},
        "hostPort": ${var.container_specs.port},
        "protocol": "tcp"
      }
    ],
    "environment": [
      {"name": "RDS_HOSTNAME", "value": "${var.rds_env_vars.db_hostname}"},
      {"name": "RDS_PORT", "value": "${var.rds_env_vars.port}"},
      {"name": "DB_NAME", "value": "${var.rds_env_vars.db_name}"},
      {"name": "RDS_USERNAME", "value": "${var.rds_env_vars.user}"},
      {"name": "RDS_PASSWORD", "value": "${var.rds_env_vars.password}"}
    ],
    "mountPoints": [
      {
        "containerPath": "/mnt",
        "sourceVolume": "${var.name}-efs-volume"
      }
    ]
  }
]
DEFINITION
}


resource "aws_security_group" "task_sg" {
  name   = "${var.container_specs.image.name}-ecs-task-security-group"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_specs.port
    to_port         = var.container_specs.port
    security_groups = [var.load_balancer_security_group_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_service" "service" {
  name             = "${var.container_specs.image.name}-ecs-service"
  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.task.family
  launch_type      = "FARGATE"
  platform_version = "1.4.0" # FARGATE version "1.4.0" allows attaching EFS volumes

  network_configuration {
    security_groups  = [aws_security_group.task_sg.id]
    subnets          = [for id in var.private_subnet_ids : id]
    assign_public_ip = false
  }

  # leave desired_count at 1.
  # when changes to the TF configuration are made,
  # if this is null, then no tasks are created
  # until the autoscaling takes over.
  desired_count = 1

  load_balancer {
    target_group_arn = var.load_balancer_target_group_id
    container_name   = var.container_specs.image.name
    container_port   = var.container_specs.port
  }
}
