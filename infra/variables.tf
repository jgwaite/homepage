variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for main site S3 bucket"
  type        = string
  default     = "jw-home"
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "enable_aliases" {
  description = "Whether to attach aliases and ACM certificate to CloudFront"
  type        = bool
  default     = false
}

variable "aliases" {
  description = "CloudFront aliases to attach when enable_aliases is true"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront aliases"
  type        = string
  default     = ""
}

variable "acm_certificate_status" {
  description = "Status of the ACM certificate (use ISSUED to enable DNS aliases)"
  type        = string
  default     = "PENDING_VALIDATION"
}

variable "certificate_domain_name" {
  description = "Domain name used to look up ACM certificate status"
  type        = string
  default     = "josephwaite.ca"
}

variable "primary_domain_name" {
  description = "Primary DNS record (e.g. josephwaite.ca or dev.josephwaite.ca)"
  type        = string
  default     = ""
}

variable "primary_zone_id" {
  description = "Route53 hosted zone ID for the primary domain"
  type        = string
  default     = ""
}

variable "create_index_document" {
  description = "Whether to drop a placeholder index document in the site bucket"
  type        = bool
  default     = false
}

variable "index_document_content" {
  description = "Optional placeholder HTML for index document"
  type        = string
  default     = "<html><body><h1>josephwaite.ca placeholder</h1></body></html>"
}

variable "default_root_object" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}

variable "redirect_enabled" {
  description = "Whether to create the josephwaite.com redirect stack"
  type        = bool
  default     = false
}

variable "redirect_bucket_prefix" {
  description = "Prefix for redirect S3 bucket"
  type        = string
  default     = "jw-com-redirect"
}

variable "redirect_aliases" {
  description = "Aliases to attach to redirect CloudFront distribution"
  type        = list(string)
  default     = ["josephwaite.com"]
}

variable "redirect_acm_certificate_arn" {
  description = "ACM certificate ARN used by redirect distribution"
  type        = string
  default     = ""
}

variable "redirect_acm_certificate_status" {
  description = "Status of the redirect certificate (ISSUED to activate DNS alias)"
  type        = string
  default     = "PENDING_VALIDATION"
}

variable "redirect_domain_name" {
  description = "Domain name for redirect Route53 record"
  type        = string
  default     = "josephwaite.com"
}

variable "redirect_zone_id" {
  description = "Hosted zone ID for redirect domain"
  type        = string
  default     = ""
}

variable "redirect_target_domain" {
  description = "Target domain for josephwaite.com redirect"
  type        = string
  default     = "josephwaite.ca"
}

variable "additional_tags" {
  description = "Additional tags to merge across resources"
  type        = map(string)
  default     = {}
}
