resource "aws_sns_topic" "topic_alerting" {
  name = "ci5-${var.platform}-alert"
}

resource "aws_cloudwatch_metric_alarm" "lb_healthy_hosts" {
  alarm_name          = "${var.platform}-lb-healthy-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "Healthy host on ELB"

  dimensions {
    LoadBalancer = "${local.frontal_lb}"
  }

  alarm_actions = ["${aws_sns_topic.topic_alerting.arn}"]
}
