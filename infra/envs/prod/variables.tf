variable "bucket_prefix" {
  description = "Prefix for the prod site bucket"
  type        = string
  default     = "jw-home"
}

variable "enable_aliases" {
  description = "Flip to true when prod alias should be active"
  type        = bool
  default     = false
}

variable "aliases" {
  description = "CloudFront aliases for prod"
  type        = list(string)
  default     = ["josephwaite.ca"]
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for prod aliases"
  type        = string
  default     = "arn:aws:acm:us-east-1:463542770135:certificate/35f4c1ed-d10b-4893-8432-5e797f3730d9"
}

variable "acm_certificate_status" {
  description = "Status of the ACM cert (ISSUED to enable alias)"
  type        = string
  default     = "ISSUED"
}

variable "route53_zone_id_ca" {
  description = "Hosted zone ID for josephwaite.ca"
  type        = string
  default     = "Z02984543CL5FBRCN1GTT"
}

variable "redirect_enabled" {
  description = "Create the .com redirect when true"
  type        = bool
  default     = true
}

variable "redirect_aliases" {
  description = "Aliases for the redirect distribution"
  type        = list(string)
  default     = ["josephwaite.com"]
}

variable "redirect_acm_certificate_arn" {
  description = "ACM certificate ARN for redirect"
  type        = string
  default     = "arn:aws:acm:us-east-1:463542770135:certificate/35f4c1ed-d10b-4893-8432-5e797f3730d9"
}

variable "redirect_acm_certificate_status" {
  description = "Status of redirect certificate"
  type        = string
  default     = "ISSUED"
}

variable "redirect_zone_id_com" {
  description = "Hosted zone ID for josephwaite.com"
  type        = string
  default     = "Z02504031AR7WHL0FASQ5"
}

variable "redirect_target_domain" {
  description = "Target for josephwaite.com redirect"
  type        = string
  default     = "josephwaite.ca"
}

variable "additional_tags" {
  description = "Optional extra tags"
  type        = map(string)
  default     = {}
}
