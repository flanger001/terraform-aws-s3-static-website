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

variable "domains" {
  type        = list(string)
  description = <<-DOC
    List of domain name aliases for the site, e.g. ["mybucket.com", "my.bucket.com"].
  DOC
  nullable    = false

  validation {
    condition     = length(var.domains) > 0
    error_message = "Must add at least one domain name alias"
  }
}

variable "primary_domain" {
  type        = string
  description = "Deployed domain name, e.g. www.mybucket.com"
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
