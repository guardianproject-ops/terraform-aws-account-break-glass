output "sns_topic_arn" {
  value       = local.topic_arn
  description = "The ARN of the SNS topic that alerts are sent to"
}
