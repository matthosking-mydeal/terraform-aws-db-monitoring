resource "aws_cloudwatch_metric_alarm" "low_memory" {
  alarm_name          = "${var.account_name}-db-${var.identifier}-low-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.low_memory_alarm.evaluation_periods
  datapoints_to_alarm = var.low_memory_alarm.data_points
  threshold           = var.low_memory_alarm.threshold_in_gb
  treat_missing_data  = "missing"
  alarm_description   = "Database instance memory above threshold"
  alarm_actions       = [var.alarm_sns_topics]
  ok_actions          = [var.alarm_sns_topics]

  metric_query {
    id = "e1"
    expression  = "m1/1000000000"
    label       = "MemoryInGB"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "FreeableMemory"
      namespace   = "AWS/RDS"
      period      = var.low_memory_alarm.period
      stat        = "Minimum"

      dimensions = {
        DBInstanceIdentifier = var.identifier
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.account_name}-db-${var.identifier}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_usage_alarm.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.cpu_usage_alarm.period
  statistic           = "Maximum"
  threshold           = var.cpu_usage_alarm.threshold_in_percentage
  treat_missing_data  = "missing"
  alarm_description   = "Database instance CPU above threshold"
  alarm_actions       = [var.alarm_sns_topics]
  ok_actions          = [var.alarm_sns_topics]

  dimensions = {
    DBInstanceIdentifier = var.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "low_disk" {
  alarm_name          = "${var.account_name}-db-${var.identifier}-low-disk"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.low_disk_alarm.evaluation_periods
  datapoints_to_alarm = var.low_disk_alarm.data_points
  threshold           = var.low_disk_alarm.threshold_in_gb
  treat_missing_data  = "missing"
  alarm_description   = "Database instance disk space is low"
  alarm_actions       = [var.alarm_sns_topics]
  ok_actions          = [var.alarm_sns_topics]

  metric_query {
    id = "e1"
    expression  = "m1/1000000000"
    label       = "FreeDiskSpace"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "FreeStorageSpace"
      namespace   = "AWS/RDS"
      period      = var.low_disk_alarm.period
      stat        = "Maximum"

      dimensions = {
        DBInstanceIdentifier = var.identifier
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "blocked_processes" {
  count               = (var.resource_id != "") ? 1 : 0
  alarm_name          = "${var.account_name}-db-${var.identifier}-blocked-processes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.blocked_processes_alarm.evaluation_periods
  datapoints_to_alarm = var.blocked_processes_alarm.data_points
  threshold           = var.blocked_processes_alarm.threshold
  treat_missing_data  = "missing"
  alarm_description   = "Blocked processes above threshold"
  alarm_actions       = [var.alarm_sns_topics]
  ok_actions          = [var.alarm_sns_topics]

  metric_query {
    id = "e1"
    expression  = "DB_PERF_INSIGHTS('RDS', '${var.resource_id}', 'db.General Statistics.Processes blocked.avg')"
    label       = "db.General Statistics.Processes blocked"
    period      = var.blocked_processes_alarm.period
    return_data = "true"
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credits" {
  count = substr(var.instance_class, 0, 4) == "db.t" ? 1 : 0

  alarm_name          = "${var.account_name}-db-${var.identifier}-low-cpu-credits"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Maximum"
  threshold           = "100"
  alarm_description   = "Database instance CPU credit balance is low"
  alarm_actions       = [var.alarm_sns_topics]
  ok_actions          = [var.alarm_sns_topics]

  dimensions = {
    DBInstanceIdentifier = var.identifier
  }
}

# resource "aws_cloudwatch_metric_alarm" "read_latency" {
#   alarm_name                = "${var.account_name}-db-${var.identifier}-read-latency"
#   comparison_operator       = "LessThanLowerOrGreaterThanUpperThreshold"
#   # evaluation_periods        = "3"
#   threshold                 = "0"
#   # datapoints_to_alarm       = "2"
#   metric_query {
#     id = "ad1"
#     label = "ReadLatency (expected)"
#     return_data = true
#     expression = "ANOMALY_DETECTION_BAND(m1, 2)"
#   }
#   metric_query {
#     id = "m1"

#     metric {
#       metric_name = "ReadLatency"
#       namespace   = "AWS/RDS"
#       period      = "600"
#       stat        = "Average"

#       dimensions = {
#         DBInstanceIdentifier = var.identifier
#       }
#     }
#   }
#   threshold_metric_id = "ad1"
#   treat_missing_data        = "missing"
#   alarm_description         = "Database instance read latency"
#   alarm_actions             = var.alarm_sns_topics
#   ok_actions                = var.alarm_sns_topics
# }
