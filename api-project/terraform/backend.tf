terraform {
  backend "s3" {
    bucket = "onge-dev-test"
    key    = "terraform/backend.tf"
    region = "us-east-1"
  }
}
