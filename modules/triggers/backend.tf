terraform {
    backend "s3" {
    bucket = "cloudspice.tk"
    encrypt = true
    key = "state.tfstate"
    region = "us-east-2"
    profile = "default"
  }
}
