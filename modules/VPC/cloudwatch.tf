# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-metrics.html

resource "aws_cloudwatch_metric_alarm" "rds_requests_alarm" {
  alarm_description   = "Monitors the number of successful or failing attempts to connect to an instance."
  alarm_name          = "${var.name}-cloudwatch-rds-requests-alarm"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "2"
  evaluation_periods  = "3"
  namespace           = "AWS/RDS"
  metric_name         = "ConnectionAttempts"
  period              = "10"
  statistic           = "Sum"
  threshold           = "5"
  treat_missing_data  = "missing"
  unit                = "Count"
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}




