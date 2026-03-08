############################################
# SNS Topic
############################################

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for triage alerts"
  value       = aws_sns_topic.triage_alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic used for triage alerts"
  value       = aws_sns_topic.triage_alerts.name
}

############################################
# Lambda Triage Agent
############################################

output "triage_lambda_arn" {
  description = "ARN of the AI triage Lambda function"
  value       = aws_lambda_function.triage_agent.arn
}

output "triage_lambda_name" {
  description = "Name of the AI triage Lambda function"
  value       = aws_lambda_function.triage_agent.function_name
}

############################################
# CloudWatch Log Groups
############################################

output "service_log_group_names" {
  description = "CloudWatch log group names for all microservices"
  value = {
    for service, log in aws_cloudwatch_log_group.service_logs :
    service => log.name
  }
}

output "service_log_group_arns" {
  description = "CloudWatch log group ARNs for all microservices"
  value = {
    for service, log in aws_cloudwatch_log_group.service_logs :
    service => log.arn
  }
}

############################################
# Metric Filters
############################################

output "workflow_duration_metric_filter" {
  description = "Metric filter extracting workflow step duration"
  value       = aws_cloudwatch_log_metric_filter.workflow_duration.name
}

output "extraction_confidence_metric_filter" {
  description = "Metric filter extracting extraction confidence"
  value       = aws_cloudwatch_log_metric_filter.extraction_confidence.name
}

output "api_error_metric_filter" {
  description = "Metric filter extracting API errors"
  value       = aws_cloudwatch_log_metric_filter.api_errors.name
}

############################################
# CloudWatch Alarm Names
############################################

output "alarm_names" {
  description = "Map of CloudWatch alarm names created by the telemetry module"

  value = {
    api_error_alarm            = aws_cloudwatch_metric_alarm.api_error_alarm.alarm_name
    workflow_duration_alarm    = aws_cloudwatch_metric_alarm.workflow_duration_alarm.alarm_name
    extraction_confidence_alarm = aws_cloudwatch_metric_alarm.extraction_confidence_alarm.alarm_name
    pod_restart_alarm          = aws_cloudwatch_metric_alarm.pod_restart_alarm.alarm_name
    latency_alarm              = aws_cloudwatch_metric_alarm.latency_alarm.alarm_name
  }
}
