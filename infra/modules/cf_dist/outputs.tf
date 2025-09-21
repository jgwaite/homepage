output "distribution_id" {
  value       = aws_cloudfront_distribution.this.id
  description = "CloudFront distribution ID"
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  description = "CloudFront distribution domain"
}

output "distribution_arn" {
  value       = aws_cloudfront_distribution.this.arn
  description = "CloudFront distribution ARN"
}

output "hosted_zone_id" {
  value       = "Z2FDTNDATAQYW2"
  description = "Hosted zone ID for CloudFront aliases"
}

output "origin_access_control_id" {
  value       = aws_cloudfront_origin_access_control.this.id
  description = "Origin Access Control ID"
}
