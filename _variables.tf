variable "identifier" {
  default     = ""
  description = "RDS database instance identifier"
}

variable "instance_class" {
  description = "RDS database instance class"
}

variable "alarm_sns_topics" {
  default     = ""
  description = "Alarm topics to create and alert on RDS instance metrics"
}

variable "account_name" {
  default     = ""
  description = "Name of the AWS account to identify the alarms"
}

variable "event_categories" {
  default     = "availability,deletion,failover,failure,low storage,maintenance,notification,read replica,recovery,restoration"
  description = "A list of event categories for a SourceType that you want to subscribe to. See http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Events.html"
}

variable "low_memory_alarm" {
  type = object({
    evaluation_periods           = optional(string, "1")
    data_points                  = optional(string, "1")
    period                       = optional(string, "300")
    threshold_in_gb              = optional(string, "11")
  })

  default = {}
}

variable "cpu_usage_alarm" {
  type = object({
    evaluation_periods           = optional(number, "1")
    data_points                  = optional(string, "1")
    period                       = optional(number, "300")
    threshold_in_percentage      = optional(number, "70")
  })

  default = {}
}

variable "low_disk_alarm" {
  type = object({
    evaluation_periods           = optional(number, "1")
    data_points                  = optional(string, "1")
    period                       = optional(number, "300")
    threshold_in_gb              = optional(number, "500")
  })

  default = {}
}