############################################
# CloudWatch Log Groups for Microservices
############################################

resource "aws_cloudwatch_log_group" "service_logs" {
  for_each = toset(var.service_names)

  name              = "/drzero/services/${each.key}"
  retention_in_days = var.log_retention_days

  tags = {
    Service = each.key
    System  = "drzero"
  }
}

############################################
# Metric Filter: Workflow Step Duration
############################################

resource "aws_cloudwatch_log_metric_filter" "workflow_duration" {

  name           = "workflow-step-duration"
  log_group_name = aws_cloudwatch_log_group.service_logs["workflow-engine"].name

  pattern = "{ $.workflow_step_duration_ms = * }"

  metric_transformation {
    name      = "WorkflowStepDuration"
    namespace = "DrZero/Workflow"
    value     = "$.workflow_step_duration_ms"
  }
}


############################################
# Metric Filter: Extraction Confidence
############################################

resource "aws_cloudwatch_log_metric_filter" "extraction_confidence" {

  name           = "extraction-confidence"
  log_group_name = aws_cloudwatch_log_group.service_logs["extraction-service"].name

  pattern = "{ $.extraction_confidence = * }"

  metric_transformation {
    name      = "ExtractionConfidence"
    namespace = "DrZero/AI"
    value     = "$.extraction_confidence"
  }
}


############################################
# Metric Filter: API Errors
############################################

resource "aws_cloudwatch_log_metric_filter" "api_errors" {

  name           = "api-error-count"
  log_group_name = aws_cloudwatch_log_group.service_logs["gateway-api"].name
  pattern        = "ERROR"

  metric_transformation {
    name      = "ApiErrors"
    namespace = "DrZero/API"
    value     = "1"
  }
}

############################################
# SNS Topic for Alert Routing
############################################

resource "aws_sns_topic" "triage_alerts" {
  name = "drzero-triage-alerts"

  tags = {
    System = "drzero"
    Role   = "incident-routing"
  }
}

############################################
# IAM Role for Lambda
############################################

resource "aws_iam_role" "triage_lambda_role" {

  name = "drzero-triage-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

############################################
# IAM Policy Attachment for Logs
############################################

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {

  role       = aws_iam_role.triage_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

############################################
# Lambda Stub: AI Triage Agent
############################################

resource "aws_lambda_function" "triage_agent" {

  function_name = "drzero-ai-triage-agent"

  filename         = "lambda_stub.zip"
  source_code_hash = filebase64sha256("lambda_stub.zip")

  handler = "handler.main"
  runtime = "python3.11"

  role = aws_iam_role.triage_lambda_role.arn

  timeout = 30
  memory_size = 256

  environment {
    variables = {
      SNS_TOPIC = aws_sns_topic.triage_alerts.arn
    }
  }

  tags = {
    System = "drzero"
    Role   = "ai-triage"
  }
}

############################################
# Allow SNS to Invoke Lambda
############################################

resource "aws_lambda_permission" "sns_invoke_lambda" {

  statement_id  = "AllowSNSToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.triage_agent.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.triage_alerts.arn
}

############################################
# Subscribe Lambda to SNS Topic
############################################

resource "aws_sns_topic_subscription" "triage_lambda_subscription" {

  topic_arn = aws_sns_topic.triage_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.triage_agent.arn
}

############################################
# CloudWatch Alarm: API Error Rate
############################################

resource "aws_cloudwatch_metric_alarm" "api_error_alarm" {

  alarm_name          = "drzero-api-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1

  metric_name = "ApiErrors"
  namespace   = "DrZero/API"

  period    = 60
  statistic = "Sum"

  threshold = var.api_error_rate_threshold

  alarm_actions = [aws_sns_topic.triage_alerts.arn]

  tags = {
    Playbook = "api-error-investigation"
  }
}

############################################
# CloudWatch Alarm: Workflow Step Duration
############################################

resource "aws_cloudwatch_metric_alarm" "workflow_duration_alarm" {

  alarm_name          = "drzero-workflow-step-slow"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1

  metric_name = "WorkflowStepDuration"
  namespace   = "DrZero/Workflow"

  period    = 60
  statistic = "Average"

  threshold = var.workflow_duration_threshold_ms

  alarm_actions = [aws_sns_topic.triage_alerts.arn]

  tags = {
    Playbook = "workflow-performance-investigation"
  }
}

############################################
# CloudWatch Alarm: Extraction Confidence
############################################

resource "aws_cloudwatch_metric_alarm" "extraction_confidence_alarm" {

  alarm_name          = "drzero-low-extraction-confidence"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1

  metric_name = "ExtractionConfidence"
  namespace   = "DrZero/AI"

  period    = 300
  statistic = "Average"

  threshold = var.extraction_confidence_min

  alarm_actions = [aws_sns_topic.triage_alerts.arn]

  tags = {
    Playbook = "ai-model-quality-check"
  }
}

############################################
# CloudWatch Alarm: Pod Restart Loop
############################################

resource "aws_cloudwatch_metric_alarm" "pod_restart_alarm" {

  alarm_name          = "drzero-pod-restart-loop"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1

  metric_name = "pod_restart_count"
  namespace   = "ContainerInsights"

  period    = 300
  statistic = "Sum"

  threshold = var.pod_restart_threshold

  alarm_actions = [aws_sns_topic.triage_alerts.arn]

  tags = {
    Playbook = "pod-restart-loop"
  }
}

############################################
# CloudWatch Alarm: API Latency Spike
############################################

resource "aws_cloudwatch_metric_alarm" "latency_alarm" {

  alarm_name          = "drzero-api-latency-spike"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1

  metric_name = "ApiLatencyP95"
  namespace   = "DrZero/API"

  period    = 60
  statistic = "Average"

  threshold = var.latency_threshold_ms

  alarm_actions = [aws_sns_topic.triage_alerts.arn]

  tags = {
    Playbook = "latency-spike-investigation"
  }
}
