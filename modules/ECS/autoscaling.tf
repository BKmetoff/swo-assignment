# sources:

# https://dev.to/kieranjen/ecs-fargate-service-auto-scaling-with-terraform-2ld
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target#ecs-service-autoscaling
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#ecs-service-autoscaling

# Since the web app does not need
# a lot of resources to run,
# do demonstrate the autoscaling
# the values are set to a small number,
# as they represent a percentage
# of the respective resource

resource "aws_appautoscaling_target" "ecs_service_autoscaling_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.name}-app-autoscaling-policy-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_autoscaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_autoscaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 15
  }
}

resource "aws_appautoscaling_policy" "memory" {
  name               = "${var.name}-app-autoscaling-policy-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_autoscaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_autoscaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 10
  }
}



data "aws_iam_policy_document" "ecs_service_scaling" {
  statement {
    effect = "Allow"

    resources = ["*"]
    actions = [
      "application-autoscaling:*",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricAlarm",
      "ecs:DeregisterContainerInstance",
      "ecs:DescribeServices",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecs:UpdateContainerInstancesState",
      "ecs:UpdateService",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "iam:CreateServiceLinkedRole",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

  }
}

resource "aws_iam_policy" "ecs_service_scaling" {
  name        = "${var.name}-ecs-service-scaling-policy"
  description = "Allow ecs service scaling"

  policy = data.aws_iam_policy_document.ecs_service_scaling.json
}

resource "aws_iam_role_policy_attachment" "ecs_service_scaling" {
  role       = aws_iam_role.ecs_rds_access_role.name
  policy_arn = aws_iam_policy.ecs_service_scaling.arn
}
