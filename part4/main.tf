terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "telemetry" {
  source = "./modules/telemetry"

  service_names = var.service_names

  log_retention_days = var.log_retention_days

  api_error_rate_threshold       = var.api_error_rate_threshold
  workflow_duration_threshold_ms = var.workflow_duration_threshold_ms
  extraction_confidence_min      = var.extraction_confidence_min

  pod_restart_threshold  = var.pod_restart_threshold
  latency_threshold_ms   = var.latency_threshold_ms
}
