variable "cloudwatch_alarm_name" {
  description = "The name of the alarm"
  type        = string
  default = "high_cpu_usage"
}

variable "cloudwatch_alarm_comparison_operator" {
  description = "The comparison operator for the alarm"
  type        = string
}

variable "cloudwatch_alarm_evaluation_periods" {
  description = "The number of periods to evaluate the metric"
  type        = number
  default = 2
}

variable "cloudwatch_alarm_metric_name" {
  description = "The name of the metric to monitor"
  type        = string
  default = "CPUUtilization"
}

variable "cloudwatch_alarm_namespace" {
  description = "The namespace of the metric"
  type        = string
  default = "AWS/EC2"
}

variable "cloudwatch_alarm_period" {
  description = "The period of the metric"
  type        = number
  default = 30
}

variable "cloudwatch_alarm_statistic" {
  description = "The statistic to apply to the metric"
  type        = string
  default = "Average"
}

variable "cloudwatch_alarm_threshold" {
  description = "The threshold to trigger the alarm"
  type        = number
  default = 25
}

variable "cloudwatch_alarm_description" {
  description = "The description of the alarm"
  type        = string
  default = "This metric monitors ec2 instance CPU utilization"
}

variable "cloudwatch_alarm_actions" {
  description = "The actions to take when the alarm triggers"
  type        = list(string)
}

variable "cloudwatch_alarm_dimensions" {
  description = "The dimensions to apply to the metric"
  type        = map(string)
}