terraform {
  backend "s3" {
    bucket         = "my-27-state-bucket"
    key            = "global/s3/order_app.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}
