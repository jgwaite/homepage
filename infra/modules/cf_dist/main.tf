locals {
  tags = merge(var.tags, {
    Environment = var.environment
  })

  use_default_certificate = var.acm_certificate_arn == null || var.acm_certificate_arn == "" || length(var.aliases) == 0

  origin_id = format("s3-%s", var.bucket_name)
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = format("%s-%s-oac", var.bucket_name, var.environment)
  description                       = format("OAC for %s", var.bucket_name)
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.comment
  price_class         = var.price_class
  default_root_object = var.default_root_object
  aliases             = var.aliases

  origin {
    domain_name              = var.bucket_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    target_origin_id         = local.origin_id
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = local.use_default_certificate ? null : var.acm_certificate_arn
    ssl_support_method             = local.use_default_certificate ? null : "sni-only"
    minimum_protocol_version       = local.use_default_certificate ? null : "TLSv1.2_2021"
    cloudfront_default_certificate = local.use_default_certificate
  }

  http_version = "http2and3"
  tags         = local.tags
}
