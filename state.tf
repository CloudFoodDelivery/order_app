terraform {
  backend "s3" {
    bucket         = "fds-state-bucket"
    key            = "fds"
    region         = "us-east-2"
    dynamodb_table = "fds-state-table"
  }
}
