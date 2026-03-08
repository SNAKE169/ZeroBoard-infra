output "sns_topic_arn" {
  value = module.telemetry.sns_topic_arn
}

output "triage_lambda_arn" {
  value = module.telemetry.triage_lambda_arn
}
