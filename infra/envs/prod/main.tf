terraform {
  backend "local" {}
}

module "homepage" {
  source = "../.."

  environment            = "prod"
  bucket_prefix          = var.bucket_prefix
  enable_aliases         = var.enable_aliases
  aliases                = var.aliases
  acm_certificate_arn    = var.acm_certificate_arn
  acm_certificate_status = var.acm_certificate_status
  primary_zone_id        = var.route53_zone_id_ca
  primary_domain_name    = length(var.aliases) > 0 ? var.aliases[0] : ""
  create_index_document  = false
  additional_tags        = var.additional_tags

  redirect_enabled                = var.redirect_enabled
  redirect_aliases                = var.redirect_aliases
  redirect_acm_certificate_arn    = var.redirect_acm_certificate_arn
  redirect_acm_certificate_status = var.redirect_acm_certificate_status
  redirect_zone_id                = var.redirect_zone_id_com
  redirect_domain_name            = length(var.redirect_aliases) > 0 ? var.redirect_aliases[0] : var.redirect_target_domain
  redirect_target_domain          = var.redirect_target_domain
}
