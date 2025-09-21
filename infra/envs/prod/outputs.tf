output "bucket_name" {
  value       = module.homepage.bucket_name
  description = "Prod site bucket"
}

output "distribution_id" {
  value       = module.homepage.distribution_id
  description = "Prod CloudFront distribution ID"
}

output "distribution_domain_name" {
  value       = module.homepage.distribution_domain_name
  description = "Prod CloudFront domain"
}

output "redirect_distribution_id" {
  value       = module.homepage.redirect_distribution_id
  description = "Redirect CloudFront distribution ID"
}

output "redirect_distribution_domain" {
  value       = module.homepage.redirect_distribution_domain
  description = "Redirect CloudFront domain"
}
