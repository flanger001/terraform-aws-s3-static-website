# Bucket
resource "aws_s3_bucket" "bucket" {
  bucket_prefix       = null
  force_destroy       = true
  object_lock_enabled = false
  bucket              = var.bucket_name

  tags = {
    Application = var.application
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version   = "2008-10-17",
    Id        = "PolicyForCloudFrontPrivateContent",
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal",
        Effect    = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.distribution.arn
          }
        }
      }
    ]
  })
}

# Cloudfront
resource "aws_cloudfront_distribution" "distribution" {
  aliases                         = var.domains
  comment                         = var.application
  continuous_deployment_policy_id = null
  default_root_object             = "index.html"
  enabled                         = true
  http_version                    = "http2"
  is_ipv6_enabled                 = true
  price_class                     = "PriceClass_All"
  retain_on_delete                = false
  staging                         = false

  tags = {
    Application = var.application
  }

  wait_for_deployment = true
  web_acl_id          = null

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = data.aws_cloudfront_cache_policy.disabled.id
    cached_methods             = ["GET", "HEAD"]
    compress                   = false
    default_ttl                = 0
    field_level_encryption_id  = null
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = null
    realtime_log_config_arn    = null
    response_headers_policy_id = null
    smooth_streaming           = false
    # Note that target_origin_id must match origin.origin_id
    target_origin_id           = var.application
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.function.arn
    }
  }

  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.access_control.id
    # Note that origin_id is a label
    origin_id                = var.application
    origin_path              = null
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = data.aws_acm_certificate.certificate.arn
    cloudfront_default_certificate = false
    iam_certificate_id             = null
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "access_control" {
  description                       = var.application
  name                              = aws_s3_bucket.bucket.bucket_regional_domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "function" {
  code = templatefile(
    "${path.module}/function.tftpl",
    {
      redirectable_domains = module.records.redirects
      domain_name          = var.primary_domain
    }
  )
  comment = "Directory serving index.html and subdomain redirection function for ${var.application}"
  name    = var.cloudfront_function_name
  publish = true
  runtime = "cloudfront-js-2.0"
}

# Route53
resource "aws_route53_record" "records" {
  for_each = {
    for zone_record in module.records.zones :
    "${zone_record.zone}_${zone_record.record}_${zone_record.record_type}" => zone_record
    if zone_record.record_type != "A"
  }
  allow_overwrite = null
  health_check_id = null
  name            = each.value.record
  records         = [aws_cloudfront_distribution.distribution.domain_name]
  set_identifier  = null
  ttl             = local.ttl.short
  type            = each.value.record_type
  zone_id         = data.aws_route53_zone.zones[each.value.zone].id
}

resource "aws_route53_record" "aliases" {
  for_each = {
    for zone_record in module.records.zones : "${zone_record.zone}_${zone_record.record}_${zone_record.record_type}" => zone_record
    if zone_record.record_type == "A"
  }
  allow_overwrite = null
  health_check_id = null
  name            = each.value.record
  set_identifier  = null
  type            = "A"
  zone_id         = data.aws_route53_zone.zones[each.value.zone].id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
  }
}

# Data
data "aws_caller_identity" "account" {}

data "aws_acm_certificate" "certificate" {
  domain = var.certificate_name
}

data "aws_route53_zone" "zones" {
  for_each = module.records.mapped_zones
  name     = each.key
}

data "aws_cloudfront_cache_policy" "disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

# Records
module "records" {
  source  = "./modules/records"
  primary = var.primary_domain
  domains = var.domains
}
