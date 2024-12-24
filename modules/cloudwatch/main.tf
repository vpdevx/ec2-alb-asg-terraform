resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = var.cloudwatch_alarm_name
  comparison_operator = var.cloudwatch_comparison_operator
  evaluation_periods  = var.cloudwatch_evaluation_periods
  metric_name         = var.cloudwatch_metric_name
  namespace           = var.cloudwatch_namespace
  period              = var.cloudwatch_period
  statistic           = var.cloudwatch_statistic
  threshold           = var.cloudwatch_treshold
  alarm_description   = var.cloudwatch_alarm_description
  alarm_actions       = var.cloudwatch_alarm_actions
  dimensions = var.cloudwatch_dimensions
}