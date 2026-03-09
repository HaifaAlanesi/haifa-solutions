terraform {
  backend "s3" {
    bucket         = "haifa-terraform-state-storage" # The name you used above
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}



# --- 1. PROVIDERS ---
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# --- 2. S3 BUCKET CONFIGURATION ---
resource "aws_s3_bucket" "website_bucket" {
  bucket = "haifa-work-storage" # Your existing bucket name
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id
  index_document { suffix = "index.html" }
}

# --- 3. CLOUDFRONT & SSL (The Security Layer) ---
resource "aws_acm_certificate" "cert" {
  provider          = aws.us_east_1
  domain_name       = "haifa.work"
  validation_method = "DNS"
  subject_alternative_names = ["www.haifa.work"]
  lifecycle { create_before_destroy = true }
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "s3_oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
# --- 3.5 CLOUDFRONT DISTRIBUTION ---
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = "S3-haifa-work-storage"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["haifa.work", "www.haifa.work"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-haifa-work-storage"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# --- 4. THE BUCKET POLICY (The "Missing Piece") ---
resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}
