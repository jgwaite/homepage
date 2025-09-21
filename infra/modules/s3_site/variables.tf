variable "bucket_name" {
  description = "Fully qualified bucket name"
  type        = string
}

variable "environment" {
  description = "Environment tag value"
  type        = string
}

variable "tags" {
  description = "Base tags to merge"
  type        = map(string)
  default     = {}
}

variable "create_index_document" {
  description = "Whether to upload a placeholder index.html"
  type        = bool
  default     = false
}

variable "index_document_content" {
  description = "Placeholder HTML content"
  type        = string
  default     = "<html><body><h1>Coming soon</h1></body></html>"
}

variable "cloudfront_distribution_source_arns" {
  description = "List of CloudFront distribution ARNs allowed to read from this bucket"
  type        = list(string)
  default     = []
}
