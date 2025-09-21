output "bucket_name" {
  value       = module.homepage.bucket_name
  description = "Dev site bucket"
}

output "distribution_id" {
  value       = module.homepage.distribution_id
  description = "Dev CloudFront distribution ID"
}

output "distribution_domain_name" {
  value       = module.homepage.distribution_domain_name
  description = "Dev CloudFront domain"
}
