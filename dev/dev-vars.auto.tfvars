region = "eu-west-2"
azs = [ "eu-west-2a", "eu-west-2b" ]
account_id = 071846798064
env = "dev"

dynamics_host = ""
dynamics_path = ""

datadog_account_id = ""
datadog_external_id = ""

file_upload_expiry_time = "6000"
file_service_base_url = ""

secretsmanager_vpce_endpoint = "https://secretsmanager.eu-west-2.amazonaws.com"

domain_name = ""
claim_app_port = 8081
claim_app_count = 1
claim_app_name = "claim"
claim_fargate_cpu = 1024
claim_fargate_memory = 2048
claim_image_uri = "071846798064.dkr.ecr.eu-west-2.amazonaws.com/dev-claim:v1.1.26"

mockserver_image_uri = "mockserver/mockserver:latest"
mockserver_app_port = 1080
mockserver_fargate_cpu = 1024
mockserver_fargate_memory = 2048
mockserver_app_count = 1

eligibility_app_port = 8081
eligibility_app_count = 1
eligibility_app_name = "eligibility"
eligibility_fargate_cpu = 1024
eligibility_fargate_memory = 2048
eligibility_image_uri = "071846798064.dkr.ecr.eu-west-2.amazonaws.com/dev-eligibility:v1.1.37"

alb_cert_arn = "arn:aws:acm:eu-west-2:071846798064:certificate/6106f6bc-46ef-4da8-8364-1c3edcbe920b"

claim_reference_expiration_time = 6000

eligibility_url = ""
claim_url = ""

api_url = ""
claim_queue_url = "https://sqs.eu-west-2.amazonaws.com/071846798064/claims-sqs"
redis_host = ""
session-timeout = "1800"
timeout-warning = "300"
timeout-final-warning = "10"
session-timeout-redirect = ""
eligibility-session-timeout-redirect = ""
claim-session-timeout-redirect = ""
start-url = ""
eligibility_timeout_redirect_name = ""
claim_timeout_redirect_name = ""

# rds
allocated_storage = 20
instance_class = "db.t2.small"
multi_az = false
postgres_engine_version = "12.5"

ssm_vpce_endpoint = "https://ssm.eu-west-2.amazonaws.com"
csv-loader-lambda-file-name = ""
claims_lambda_expiry_time = 365
mti_cron_trigger_schedule = "cron(0 14 ? * 2-6 *)"
