terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#--------------------------
#S3 Bucket and Configuration
#--------------------------

resource "aws_s3_bbucket" "s3_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Enviornment = "Dev"
  }
}
###sets public access block configuration
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls   = false
  block_public_policy = false
}

##Set bucket policy to make it publicly accessible
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "Statement1",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })
}
######################################
##ROUTE53 HOSTED ZON & RECORDS
######################################

#Hosted zone for your Route 53 domain
resource "aws_route53_zone" "main" {
  name = var.domain_name
}

