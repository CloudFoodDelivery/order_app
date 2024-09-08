# CloudFront Configuration
variable "cloudfront_price_class" {
  description = "The CloudFront price class."
  type        = string
  default     = "PriceClass_All"
}

variable "region" {
  type = string
}