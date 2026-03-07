output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "certificate_arn" {
  description = "The ARN of the issued certificate"
  value       = aws_acm_certificate.cert.arn
}
