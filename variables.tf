variable "bucket_name" {
  type        = string
  description = "Name of the bucket, e.g. my-bucket"
  nullable    = false
}

variable "application" {
  type        = string
  description = "Name of the actual application, e.g. My Bucket website"
  nullable    = false
}

variable "canonical_domain_name" {
  type        = string
  description = "Deployed domain name, e.g. www.mybucket.com"
  nullable    = false
}

variable "domain_aliases" {
  type        = list(string)
  description = "List of domain name aliases for the site, e.g. [\"mybucket.com\", \"my.bucket.com\"]"
  nullable    = false
}

variable "function_name" {
  type        = string
  description = "Name for CloudFront function, e.g. MyFunction"
  nullable    = false
}

variable "redirectable_domains" {
  type        = list(string)
  description = "List of redirectable domains for the site, e.g. [\"mybucket.com\", \"my.bucket.com\"]"
  nullable    = false
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
