output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "Redirect bucket name"
}

output "distribution_id" {
  value       = aws_cloudfront_distribution.this.id
  description = "Redirect CloudFront distribution ID"
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  description = "Redirect CloudFront distribution domain"
}

output "hosted_zone_id" {
  value       = "Z2FDTNDATAQYW2"
  description = "Hosted zone ID for CloudFront"
}
