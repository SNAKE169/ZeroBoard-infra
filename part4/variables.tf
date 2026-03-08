variable "aws_region" {
  default = "us-east-1"
}

variable "service_names" {
  description = "List of microservices"
  type        = list(string)

  default = [
    "workflow-engine",
    "extraction-service",
    "search-service",
    "validation-service",
    "document-service",
    "nl-query-service",
    "gateway-api"
  ]
}

variable "log_retention_days" {
  default = 14
}

variable "api_error_rate_threshold" {
  default = 5
}

variable "workflow_duration_threshold_ms" {
  default = 10000
}

variable "extraction_confidence_min" {
  default = 0.85
}

variable "pod_restart_threshold" {
  default = 3
}

variable "latency_threshold_ms" {
  default = 2500
}
