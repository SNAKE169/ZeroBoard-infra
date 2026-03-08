variable "service_names" {
  type = list(string)
}

variable "log_retention_days" {
  type = number
}

variable "api_error_rate_threshold" {
  type = number
}

variable "workflow_duration_threshold_ms" {
  type = number
}

variable "extraction_confidence_min" {
  type = number
}

variable "pod_restart_threshold" {
  type = number
}

variable "latency_threshold_ms" {
  type = number
}
