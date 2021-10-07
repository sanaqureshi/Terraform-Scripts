variable "region" {
  type = string
  default = "us-east-2"
}

variable "managed_policies" {
  default = ["arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
             "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole",
             "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
             "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  ]
}
