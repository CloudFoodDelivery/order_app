resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name

  tags = {
    Name        = "WebsiteBucket"
    Environment = "Production"
  }

  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.bucket
  key          = "index.html"
  source       = "${path.module}/Frontend/index.html"
  content_type = "text/html"

  acl = "public-read"

  depends_on = [aws_s3_bucket.website]
}
