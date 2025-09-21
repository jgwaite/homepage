variable "environment" {
  description = "Environment tag value"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name used as origin"
  type        = string
}

variable "bucket_domain_name" {
  description = "S3 bucket domain (virtual-hosted)"
  type        = string
}

variable "default_root_object" {
  description = "Default root object served by CloudFront"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "aliases" {
  description = "Optional aliases"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "Optional ACM certificate ARN"
  type        = string
  default     = null
}

variable "comment" {
  description = "Distribution comment"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Base tags"
  type        = map(string)
  default     = {}
}
