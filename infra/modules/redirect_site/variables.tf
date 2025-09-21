variable "bucket_name" {
  description = "S3 bucket name for redirect"
  type        = string
}

variable "environment" {
  description = "Environment tag value"
  type        = string
}

variable "tags" {
  description = "Base tags"
  type        = map(string)
  default     = {}
}

variable "aliases" {
  description = "Aliases to attach to the redirect distribution"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (must be ISSUED)"
  type        = string
}

variable "redirect_target_domain" {
  description = "Target domain for the redirect"
  type        = string
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}
