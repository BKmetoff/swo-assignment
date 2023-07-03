# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html#target-metric-table

resource "aws_cloudwatch_metric_alarm" "requests_alarm" {
  count = length(var.availability_zones)

  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html
  # The configuration below is for demonstration purposes.
  #
  # Evaluate a period of 10 minutes.
  # if more than 5 requests hit the ELB target group within
  # a single 10-minute period, the alarm will go to ALARM state.
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  threshold           = "20"
  period              = "600"

  alarm_description   = "Monitors the number of requests received by each target in an ELB target group."
  alarm_name          = "${var.name}-cloudwatch-elb-target-requests-alarm-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "RequestCountPerTarget"
  statistic           = "Sum"
  treat_missing_data  = "missing"
  dimensions = {
    TargetGroup      = aws_lb_target_group.lb_tg.arn_suffix
    LoadBalancer     = aws_lb.lb.arn_suffix
    AvailabilityZone = var.availability_zones[count.index]
  }
}




