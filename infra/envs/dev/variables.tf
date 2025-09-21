variable "bucket_prefix" {
  description = "Prefix for the dev site bucket"
  type        = string
  default     = "jw-home"
}

variable "enable_aliases" {
  description = "Flip to true once the dev alias and cert are ready"
  type        = bool
  default     = false
}

variable "aliases" {
  description = "CloudFront aliases for dev"
  type        = list(string)
  default     = ["dev.josephwaite.ca"]
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for aliases"
  type        = string
  default     = "arn:aws:acm:us-east-1:463542770135:certificate/35f4c1ed-d10b-4893-8432-5e797f3730d9"
}

variable "acm_certificate_status" {
  description = "Status of the ACM cert (ISSUED when ready to attach)"
  type        = string
  default     = "ISSUED"
}

variable "route53_zone_id_ca" {
  description = "Hosted zone ID for josephwaite.ca"
  type        = string
  default     = "Z02984543CL5FBRCN1GTT"
}

variable "additional_tags" {
  description = "Optional extra tags"
  type        = map(string)
  default     = {}
}
