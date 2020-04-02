#################
# CloudWatch Alarm
#################
resource "aws_cloudwatch_metric_alarm" "node" {
  count = var.enable_cpu_alarm ? local.node_count : 0

  alarm_name                = "cpu-over-75-${aws_instance.node[count.index].tags.Name}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "75"
  alarm_description         = "This SDM gateway is overutilized"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.node[count.index].id
  }
}