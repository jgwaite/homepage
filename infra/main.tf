data "aws_caller_identity" "current" {}

resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "redirect_suffix" {
  count   = var.redirect_enabled ? 1 : 0
  length  = 6
  special = false
  upper   = false
}

locals {
  base_tags = merge({
    Project   = "josephwaite-homepage"
    ManagedBy = "Terraform"
    Owner     = "joseph.waite"
  }, var.additional_tags)

  env_tags = merge(local.base_tags, {
    Environment = var.environment
  })

  bucket_name        = lower(format("%s-%s-%s", var.bucket_prefix, var.environment, random_string.bucket_suffix.result))
  bucket_domain_name = format("%s.s3.%s.amazonaws.com", local.bucket_name, var.aws_region)

  alias_ready = var.enable_aliases && lower(var.acm_certificate_status) == "issued" && length(var.aliases) > 0 && var.acm_certificate_arn != ""

  redirect_alias_ready = var.redirect_enabled && lower(var.redirect_acm_certificate_status) == "issued" && length(var.redirect_aliases) > 0 && var.redirect_acm_certificate_arn != ""

  redirect_bucket_name = var.redirect_enabled ? lower(format("%s-%s", var.redirect_bucket_prefix, random_string.redirect_suffix[0].result)) : ""
}

module "cf_site" {
  source              = "./modules/cf_dist"
  environment         = var.environment
  bucket_name         = local.bucket_name
  bucket_domain_name  = local.bucket_domain_name
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = local.alias_ready ? var.aliases : []
  acm_certificate_arn = local.alias_ready ? var.acm_certificate_arn : null
  comment             = "josephwaite-homepage ${var.environment}"
  tags                = local.base_tags
}

module "s3_site" {
  source                              = "./modules/s3_site"
  bucket_name                         = local.bucket_name
  environment                         = var.environment
  tags                                = local.base_tags
  create_index_document               = var.create_index_document
  index_document_content              = var.index_document_content
  cloudfront_distribution_source_arns = [module.cf_site.distribution_arn]
}

resource "aws_route53_record" "primary_a" {
  count = local.alias_ready && var.primary_zone_id != "" && var.primary_domain_name != "" ? 1 : 0

  zone_id = var.primary_zone_id
  name    = var.primary_domain_name
  type    = "A"

  alias {
    name                   = module.cf_site.distribution_domain_name
    zone_id                = module.cf_site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "primary_aaaa" {
  count = local.alias_ready && var.primary_zone_id != "" && var.primary_domain_name != "" ? 1 : 0

  zone_id = var.primary_zone_id
  name    = var.primary_domain_name
  type    = "AAAA"

  alias {
    name                   = module.cf_site.distribution_domain_name
    zone_id                = module.cf_site.hosted_zone_id
    evaluate_target_health = false
  }
}

module "redirect" {
  count = var.redirect_enabled ? 1 : 0

  source                 = "./modules/redirect_site"
  bucket_name            = local.redirect_bucket_name
  environment            = "redirect"
  aliases                = var.redirect_aliases
  acm_certificate_arn    = var.redirect_acm_certificate_arn
  redirect_target_domain = var.redirect_target_domain
  price_class            = var.price_class
  tags                   = local.base_tags
}

resource "aws_route53_record" "redirect_a" {
  count = var.redirect_enabled && local.redirect_alias_ready && var.redirect_zone_id != "" ? 1 : 0

  zone_id = var.redirect_zone_id
  name    = var.redirect_domain_name
  type    = "A"

  alias {
    name                   = module.redirect[0].distribution_domain_name
    zone_id                = module.redirect[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "redirect_aaaa" {
  count = var.redirect_enabled && local.redirect_alias_ready && var.redirect_zone_id != "" ? 1 : 0

  zone_id = var.redirect_zone_id
  name    = var.redirect_domain_name
  type    = "AAAA"

  alias {
    name                   = module.redirect[0].distribution_domain_name
    zone_id                = module.redirect[0].hosted_zone_id
    evaluate_target_health = false
  }
}
