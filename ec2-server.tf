provider "aws" {
  region = "us-east-2"
  access_key = ""
  secret_key = ""
}

resource "aws_instance" "myec123" {
  ami = "ami-0443305dabd4be2bc"
  instance_type = "t2.micro"
}
