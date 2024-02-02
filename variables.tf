variable "application" {
  type        = string
  description = "Name of the actual application, e.g. My Bucket website"
  nullable    = true
  default     = "My Static Website"
}

variable "bucket_name" {
  type        = string
  description = "Name of the bucket, e.g. my-bucket"
  nullable    = false
}

variable "canonical_domain_name" {
  type        = string
  description = "Deployed domain name, e.g. www.mybucket.com"
  nullable    = false
}

variable "certificate_name" {
  type        = string
  description = "ACM certificate name, e.g. example.com"
  nullable    = false
}

variable "cloudfront_function_name" {
  type        = string
  description = "Name for CloudFront function, e.g. MyFunction"
  nullable    = false
}

variable "domain_aliases" {
  type        = list(string)
  description = <<-DOC
    List of domain name aliases for the site, e.g. ["mybucket.com", "my.bucket.com"].

    This must contain at least the primary domain name for the site.
  DOC
  nullable    = false

  validation {
    condition     = length(var.domain_aliases) > 0
    error_message = "Must add at least one domain name alias"
  }
}

variable "redirectable_domains" {
  type        = list(string)
  description = <<-DOC
    List of redirectable domains for the site, e.g. ["mybucket.com", "my.bucket.com"]

    Not required if you are not doing apex redirection.
  DOC
  nullable    = true
  default     = []
}

variable "route53_domain_name" {
  type        = string
  description = "Hosted zone name for Route53, e.g. mybucket.com"
  nullable    = false
}

locals {
  tags = {
    Executor        = "Terraform"
    ApplicationType = "S3 static website"
    ApplicationHost = "AWS"
  }

  ttl = {
    vshort  = 60
    short   = 300
    medium  = 1800
    regular = 86400
  }
}
