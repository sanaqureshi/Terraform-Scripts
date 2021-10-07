resource "random_pet" "rs" {
  length = 2
}

resource "aws_s3_bucket" "b" {
  bucket = "mastek-${random_pet.rs.id}"
}

resource "aws_dynamodb_table" "b"{
  name     = "mastektable-${random_pet.rs.id}"
  hash_key = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
      name = "id"
      type = "N"
    }

  tags = {
    Terraform   = "true"
  }
}

resource "aws_sqs_queue" "mastek-sqs-dlq" {
  name = "sqsdlq-${random_pet.rs.id}"
}

resource "aws_sqs_queue" "mastek-sqs" {
  name                        = "sqs-${random_pet.rs.id}"
  kms_master_key_id           = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
  max_message_size            = 2048
  message_retention_seconds   = 25200
  receive_wait_time_seconds   = 0
  visibility_timeout_seconds  = 1800
  redrive_policy              = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.mastek-sqs-dlq.arn}\",\"maxReceiveCount\":4}"
}

resource "aws_iam_role" "func-role" {
  name = "funcrole-${random_pet.rs.id}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service =[
          "lambda.amazonaws.com"
          ]
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-role-policy" {
  count      = "${length(var.managed_policies)}"
  policy_arn = "${element(var.managed_policies, count.index)}"
  role       = "${aws_iam_role.func-role.name}"
}

resource "aws_lambda_function" "func" {
  filename      = "func.zip"
  function_name = "func-${random_pet.rs.id}"
  role          = aws_iam_role.func-role.arn
  handler       = "index.handler"
  source_code_hash = filebase64sha256("func.zip")
  runtime = "nodejs14.x"
}

resource "aws_lambda_alias" "func-alias" {
  name             = "funcalias-${random_pet.rs.id}"
  function_name    = aws_lambda_function.func.arn
  function_version = "$LATEST"
}

resource "aws_lambda_function_event_invoke_config" "lambda-invoke" {
  function_name = aws_lambda_alias.func-alias.function_name

  destination_config {
    on_failure {
      destination = aws_sqs_queue.mastek-sqs.arn
    }

    on_success {
      destination = aws_sqs_queue.mastek-sqs-dlq.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "lambda-sqsmap" {
  event_source_arn = "${aws_sqs_queue.mastek-sqs.arn}"
  function_name    = "${aws_lambda_function.func.arn}"
}

resource "aws_lambda_event_source_mapping" "lambda-dbmap" {
  event_source_arn  = "${aws_dynamodb_table.b.stream_arn}"
  function_name     = "${aws_lambda_function.func.arn}"
  starting_position = "LATEST"
}
