terraform {
  backend "s3" {
    bucket = "sqcloud.ml"
    key    = "terraform.tfstate"
    region = "us-east-2"
    shared_credentials_file = "%HOME%/.aws/credentials"
    profile = "default"
  }
}

module "dev-mastek-vpc" {
  source = "../modules/vpc/"
  azs = var.azs
  single_nat_gateway = true
}

resource "aws_ecr_repository" "dev-mastek" {
  name                 = "dev-mastek"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "dev-mastek-ecr-policy" {
  repository = aws_ecr_repository.dev-mastek.name
  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPushPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::071846798064:role/mastek-ecr",
        ]
      },
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ]
    }
  ]
}
EOF
}

module "dev-mastek-lambda" {
  source = "../modules/lambda"
  env                           = var.env
  lambda_execution_role_arn     = module.dev-mastek-iam.lambda_execution_role_arn
  lambda_sqs_execution_role_arn = module.dev-mastek-iam.lambda_sqs_execution_role_arn
  sqs_arn                       = module.dev-mastek-sqs.sqs_arn
  dynamics_host                 = var.dynamics_host
  dynamics_path                 = var.dynamics_path
  private_subnet_ids            = module.dev-mastek-vpc.private_subnets
  redis_host                    = module.dev-mastek-redis.redis_host
  redis_port                    = module.dev-mastek-redis.redis_port
  vpc_id                        = module.dev-mastek-vpc.vpc_id
  file-upload-expiry-time       = var.file_upload_expiry_time
  secretsmanager_vpce_endpoint  = var.secretsmanager_vpce_endpoint
  file-service-base-url         = var.file_service_base_url
  public_subnet_ids             = module.dev-mastek-vpc.public_subnets
  claim_reference_expiration_time = var.claim_reference_expiration_time
  lambda_basic_execution_role_arn = module.dev-mastek-iam.lambda_basic_execution_role_arn
  csv-data-queue-url              = module.dev-mastek-sqs.csv_data_queue_url
  csv-loader-lambda-file-name     = var.csv-loader-lambda-file-name
  csv-loader-s3-bucket            = module.dev-mastek-lambda.claims_csv_bucket
  claims-write-api            = module.dev-mastek-files-apigw.claims-write-api
  csv_data_sqs_arn                = module.dev-mastek-sqs.csv_data_sqs_arn
  ssm_vpce_endpoint               = var.ssm_vpce_endpoint
  api_url                     = var.api_url
  expiry_time                     = var.claims_lambda_expiry_time
  lambda_claims_insert_role_arn = module.dev-mastek-iam.lambda_claims_insert_role_arn
  claims_dynamodb_stream_arn = module.dev-mastek-dynamodb.claims_table_stream_arn
  new_claim_topic_arn = module.dev-mastek-sns.new_claim_topic_arn
  lambda_new_claim_integration_role_arn = module.dev-mastek-iam.lambda_new_claim_integration_role_arn
  claims_mti_csv_import_bucket_arn = module.dev-mastek-s3.claims_mti_csv_import_bucket_arn
  claims_mti_csv_import_bucket_id = module.dev-mastek-s3.claims_mti_csv_import_bucket_id
  lambda_claims_mti_csv_import_role_arn = module.dev-mastek-iam.lambda_claims_mti_csv_import_role_arn
  lambda_claims_mti_dynamodb_query_role_arn = module.dev-mastek-iam.lambda_claims_mti_dynamodb_query_role_arn
  lambda_claims_mti_excel_export_role_arn = module.dev-mastek-iam.lambda_claims_mti_excel_export_role_arn
  ukvi_export_bucket_name = module.dev-mastek-s3.ukvi_export_bucket_name
  mti_cron_trigger_schedule = var.mti_cron_trigger_schedule
}

module "dev-mastek-alb" {
  source = "../modules/alb"
  public_subnet_id = module.dev-mastek-vpc.public_subnets
  vpc_id = module.dev-mastek-vpc.vpc_id
  alb_cert_arn = var.alb_cert_arn
}

module "dev-mastek-iam" {
  source = "../modules/iam"
  sqs_arn = module.dev-mastek-sqs.sqs_arn
  lambda_sqs_arn = module.dev-mastek-lambda.sqs_lambda_arn
  datadog_account_id = var.datadog_account_id
  datadog_external_id = var.datadog_external_id
  account_id = var.account_id
  api_gw_id = module.dev-mastek-files-apigw.api_gw_id
  region = var.region
  env = var.env
}

module "dev-mastek-redis" {
  source = "../modules/redis"
  private_subnets = module.dev-mastek-vpc.private_subnets
  public_subnets_cidr = module.dev-mastek-vpc.public_subnets_cidr_blocks
  vpc_id = module.dev-mastek-vpc.vpc_id
  private_subnets_cidr = module.dev-mastek-vpc.private_subnets_cidr_blocks
}

module "dev-mastek-files-apigw" {
  source = "../modules/api-gateway"

  file_upload_lambda_arn        = module.dev-mastek-lambda.file_upload_lambda_arn
  file_upload_lambda_invoke_arn = module.dev-mastek-lambda.file_upload_lambda_invoke_arn
  vpc_id                            = module.dev-mastek-vpc.vpc_id
  iam_cloudwatch_arn                = module.dev-mastek-iam.iam_cloudwatch_arn
  files_list_lambda_arn         = module.dev-mastek-lambda.files_list_lambda_arn
  files_list_lambda_invoke_arn  = module.dev-mastek-lambda.files_list_lambda_invoke_arn
  region = var.region
  account_id = var.account_id
  claims-delete-claimant-lambda = module.dev-mastek-lambda.claims_delete_claimant_lambda_function_name
  claims-query-claimant-lambda = module.dev-mastek-lambda.claims_query_claimant_lambda_function_name
  claims-write-cache-lambda = module.dev-mastek-lambda.claims_delete_claimant_lambda_function_name
  claims_delete_claimant_lambda_invoke_arn = module.dev-mastek-lambda.claims_delete_claimant_lambda_invoke_arn
  claims_query_claimant_lambda_invoke_arn = module.dev-mastek-lambda.claims_query_claimant_lambda_invoke_arn
  claims_write_cache_lambda_invoke_arn = module.dev-mastek-lambda.claims_write_cache_lambda_invoke_arn
  evidence-list-lambda = module.dev-mastek-lambda.files_list_lambda_function_name
  evidence-upload-lambda = module.dev-mastek-lambda.files_upload_lambda_function_name
  file_get_lambda =  module.dev-mastek-lambda.file_get_lambda_arn
  file_get_lambda_invoke_arn = module.dev-mastek-lambda.file_get_lambda_invoke_arn
  claims_insert_lambda = module.dev-mastek-lambda.claims_insert_lambda_function_name
  claims_insert_lambda_invoke_arn = module.dev-mastek-lambda.claims_insert_lambda_invoke_arn
}

module "dev-mastek-sqs" {
  source = "../modules/sqs"

  account_id  = var.account_id
  region      = var.region
}

module "dev-mastek-dynamodb" {
  source = "../modules/dynamodb"
}

module "dev-mastek-secretsmanager" {
  source = "../modules/secretsmanager"

  lambda_security_group_id  = module.dev-mastek-lambda.lambda_sg_id
  private_subnets           = module.dev-mastek-vpc.private_subnets
  vpc_id                    = module.dev-mastek-vpc.vpc_id
}

module "dev-mastek-systemsmanager" {
  source = "../modules/systemsmanager"

  api_url                               = var.api_url
  claim_queue_url                       = var.claim_queue_url
  redis_host                            = var.redis_host
  session-timeout                       = var.session-timeout
  timeout-final-warning                 = var.timeout-final-warning
  timeout-warning                       = var.timeout-warning
  claim-session-timeout-redirect        = var.claim-session-timeout-redirect
  eligibility-session-timeout-redirect  = var.eligibility-session-timeout-redirect
  claim_timeout_redirect_name           = var.claim_timeout_redirect_name
  eligibility_timeout_redirect_name     = var.eligibility_timeout_redirect_name
  api_key                               = module.dev-mastek-files-apigw.api_key
  lambda_security_group_id                  = module.dev-mastek-lambda.lambda_sg_id
  private_subnets                           = module.dev-mastek-vpc.private_subnets
  vpc_id                                    = module.dev-mastek-vpc.vpc_id
  public_subnets                            = module.dev-mastek-vpc.public_subnets
}

module "dev-mastek-rds" {
  source = "../modules/rds"
  allocated_storage = var.allocated_storage
  instance_class = var.instance_class
  multi_az = var.multi_az
  postgres_engine_version = var.postgres_engine_version
  private_subnet_id = module.dev-mastek-vpc.private_subnets
  public_subnet_cidr = module.dev-mastek-vpc.public_subnets_cidr_blocks
  vpc_id = module.dev-mastek-vpc.vpc_id
}

module "dev-mastek-sns" {
  source = "../modules/sns"
}

module "dev-mastek-s3" {
  source = "../modules/s3"
  env = var.env
}
