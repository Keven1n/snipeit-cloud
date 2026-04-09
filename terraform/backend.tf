terraform {
  backend "s3" {
    bucket         = "snipeit-tfstate-560288546659"
    key            = "snipeit/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "snipeit-terraform-state-lock"
    encrypt        = true
  }
}
