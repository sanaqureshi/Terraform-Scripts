variable "region" {}
variable "azs" {}
variable "env" {}

variable "whitelisted_ips" {}
variable "account_id" {}

variable "dynamics_host" {}
variable "dynamics_path" {}

variable "datadog_account_id" {}
variable "datadog_external_id" {}

variable "file_upload_expiry_time" {}
variable "file_service_base_url" {}

variable "secretsmanager_vpce_endpoint" {}

variable "domain_name" {}
variable "claim_image_uri" {}
variable "claim_app_port" {}
variable "claim_fargate_cpu" {}
variable "claim_fargate_memory" {}
variable "claim_app_count" {}
variable "claim_app_name" {}

variable "mockserver_image_uri" {}
variable "mockserver_app_port" {}
variable "mockserver_fargate_cpu" {}
variable "mockserver_fargate_memory" {}
variable "mockserver_app_count" {}

variable "eligibility_image_uri" {}
variable "eligibility_app_port" {}
variable "eligibility_fargate_cpu" {}
variable "eligibility_fargate_memory" {}
variable "eligibility_app_count" {}
variable "eligibility_app_name" {}

variable "alb_cert_arn" {}

variable "claim_reference_expiration_time" {}
variable "eligibility_url" {}
variable "claim_url" {}

variable "api_url" {}
variable "claim_queue_url" {}
variable "redis_host" {}
variable "session-timeout" {}
variable "timeout-warning" {}
variable "timeout-final-warning" {}
variable "session-timeout-redirect" {}
variable "claim-session-timeout-redirect" {}
variable "eligibility-session-timeout-redirect" {}
variable "start-url" {}

variable "eligibility_timeout_redirect_name" {}
variable "claim_timeout_redirect_name" {}

# rds
variable "allocated_storage" {}
variable "instance_class" {}
variable "multi_az" {}
variable "postgres_engine_version" {}

variable "csv-loader-lambda-file-name" {}
variable "ssm_vpce_endpoint" {}

variable "claims_lambda_expiry_time" {}
variable "mti_cron_trigger_schedule" {}

