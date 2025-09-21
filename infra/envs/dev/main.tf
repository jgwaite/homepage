terraform {
  backend "local" {}
}

module "homepage" {
  source = "../.."

  environment            = "dev"
  bucket_prefix          = var.bucket_prefix
  enable_aliases         = var.enable_aliases
  aliases                = var.aliases
  acm_certificate_arn    = var.acm_certificate_arn
  acm_certificate_status = var.acm_certificate_status
  primary_zone_id        = var.route53_zone_id_ca
  primary_domain_name    = length(var.aliases) > 0 ? var.aliases[0] : ""
  create_index_document  = true
  additional_tags        = var.additional_tags

  redirect_enabled                = false
  redirect_aliases                = ["josephwaite.com"]
  redirect_acm_certificate_arn    = var.acm_certificate_arn
  redirect_acm_certificate_status = var.acm_certificate_status
}
