# #################
# # CloudWatch Alarms
# #################

# resource "aws_cloudwatch_metric_alarm" "sdm_gw_cpu" {
#   count = length(aws_instance.sdm_gateway)

#   alarm_name                = "cpu_over_80_${aws_instance.sdm_gateway[count.index].tags.Name}"
#   comparison_operator       = "GreaterThanOrEqualToThreshold"
#   evaluation_periods        = "2"
#   metric_name               = "CPUUtilization"
#   namespace                 = "AWS/EC2"
#   period                    = "300"
#   statistic                 = "Average"
#   threshold                 = "80"
#   alarm_description         = "This SDM gateway is overutilized"
#   insufficient_data_actions = []

#   dimensions = {
#     InstanceId = aws_instance.sdm_gateway[count.index].id
#   }
# }