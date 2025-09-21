output "bucket_name" {
  description = "S3 bucket name for the site"
  value       = module.s3_site.bucket_name
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3_site.bucket_arn
}

output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cf_site.distribution_id
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain"
  value       = module.cf_site.distribution_domain_name
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = module.cf_site.distribution_arn
}

output "redirect_bucket_name" {
  description = "Redirect bucket name"
  value       = var.redirect_enabled ? module.redirect[0].bucket_name : null
}

output "redirect_distribution_id" {
  description = "Redirect CloudFront distribution ID"
  value       = var.redirect_enabled ? module.redirect[0].distribution_id : null
}

output "redirect_distribution_domain" {
  description = "Redirect CloudFront domain"
  value       = var.redirect_enabled ? module.redirect[0].distribution_domain_name : null
}
