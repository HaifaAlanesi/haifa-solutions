# We need a special provider for us-east-1 to handle the SSL cert
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Request the SSL Certificate
resource "aws_acm_certificate" "cert" {
  provider          = aws.us_east_1
  domain_name       = "haifa.work"
  validation_method = "DNS"

  # This allows the cert to cover both haifa.work and www.haifa.work
  subject_alternative_names = ["www.haifa.work"]

  lifecycle {
    create_before_destroy = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create the S3 bucket for haifa.work
resource "aws_s3_bucket" "website_bucket" {
  bucket = "haifa-work-storage" # Bucket names must be unique globally
}

# Set the bucket to act as a website
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}


# This resource disables the "Block Public Access" settings
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# 1. Create the Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-website-oac"
  description                       = "Allow CloudFront to access the S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. The CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = "S3-Website-Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # Your custom domain names
  aliases = ["haifa.work", "www.haifa.work"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Website-Origin"

    # This line is the magic that forces HTTPS
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Use the certificate we requested earlier
  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:277375108185:certificate/5892d6fd-5638-4742-96d5-4cf52fa14848"

    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "production"
  }
}


resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}




# This resource attaches a policy to allow public reading
resource "aws_s3_bucket_policy" "allow_public_access" {
 
 bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      },
    ]
  })

  # Ensure the public access block is removed BEFORE applying the policy
  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}
