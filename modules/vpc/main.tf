locals {
  # VPC CIDR Range
  cidr = "10.0.0.0/16"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  cidr   = local.cidr
  name   = "mastek"
  version = "3.5.0"

  azs = var.azs

  # Two public subnets and two private subnets
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway    = true
  single_nat_gateway    = var.single_nat_gateway
  enable_vpn_gateway    = false
  enable_dns_hostnames  = true

  tags = {
    Terraform   = "true"
  }
}

# VPC Endpoints ensure the http requests remain within the AWS network and hence enhance the security.
# VPCE S3 & API Gateway
# This implementation complies with terraform 1.0
module "vpc-endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  vpc_id = module.vpc.vpc_id
  endpoints = {
    s3 = {
      service = "s3"
      service_type = "Gateway"
      subnet_ids = flatten([module.vpc.public_subnets, module.vpc.private_subnets])
      route_table_ids = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
    },
    execute-api = {
      service = "execute-api"
      security_group_ids = [aws_security_group.sqs-vpce-sg.id]
      subnet_ids = module.vpc.private_subnets
    }
  }
}

resource "aws_security_group" "sqs-vpce-sg" {
  name        = "sqs-vpce-sg"
  description = "Allows access from applications on DPS VPC port 443"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["10.0.101.0/24", "10.0.102.0/24"] #TODO parameterize
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #TODO parameterize
  }
}

#VPCE SQS
resource "aws_vpc_endpoint" "sqs-vpce" {
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.us-east-2.sqs"
  vpc_id              = module.vpc.vpc_id
  security_group_ids  = [aws_security_group.sqs-vpce-sg.id]
  subnet_ids          = module.vpc.public_subnets
  private_dns_enabled = true
}
