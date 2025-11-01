terraform {
  backend "s3" {
    bucket         = "rems-temp"
    key            = "networking/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "rems-lock"
    encrypt        = true
  }
}
