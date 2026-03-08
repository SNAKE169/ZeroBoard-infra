# Dr.Zero Telemetry Terraform Module

This Terraform configuration provisions the core telemetry infrastructure for the Dr.Zero observability platform.

Resources Created

- CloudWatch Log Groups for 7 microservices
- Metric Filters for:
  - Workflow step duration
  - Extraction confidence
  - API errors
- SNS topic for triage alert routing
- Lambda stub for the AI triage agent
- CloudWatch alarms for operational playbook triggers

Architecture Purpose

These resources power the automated incident detection pipeline used by the AI triage agent. Log metric filters extract structured signals from application logs, which feed CloudWatch alarms. Alarms publish events to SNS, which triggers the triage Lambda.



Initialize Terraform:

```
terraform init
```
Preview changes:
```
terraform plan
```
Apply infrastructure:
```
terraform apply
```


Thresholds such as latency limits, error rate triggers, and workflow duration can be configured through input variables.

Example:

* api_error_rate_threshold = 5
* workflow_duration_threshold_ms = 10000
* latency_threshold_ms = 2500


# Multi-Environment Deployment (Terragrunt, Future Work) 

To support **multiple environments (dev, staging, prod)** while reusing the same Terraform modules, we can use **Terragrunt**.

Terragrunt allows environment-specific configurations while keeping the Terraform module reusable and clean.


## Example Repository Structure
```
infra/
├── modules/
│ └── telemetry/
│ ├── main.tf
│ ├── variables.tf
│ └── outputs.tf
│
└── live/
    ├── terragrunt.hcl
    │
    ├── dev/
    │ ├── environment.hcl
    │ └── telemetry/
    │   └── terragrunt.hcl
    │
    ├── staging/
    │ ├── environment.hcl
    │ └── telemetry/
    │   └── terragrunt.hcl
    │
    └── prod/
    ├── environment.hcl
    └── telemetry/
      └── terragrunt.hcl
```

