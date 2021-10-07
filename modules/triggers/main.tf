resource "random_pet" "s3bucket" {
  length = 2
}

locals {
  bucket_name = "mastek-${random_pet.s3bucket.id}"
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.7.0"
  bucket  = local.bucket_name
}
