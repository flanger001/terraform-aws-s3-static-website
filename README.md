# Static Website

This module creates the infrastructure for a static website hosted on AWS S3 behind a Cloudfront distribution with HTTPS and HTTP-to-HTTPS redirection. All routing is through Cloudfront, and as such this does not use the S3 Static Website configuration.

Input variables are documented in [`variables.tf`](variables.tf).

This module will create these AWS resources:

- `aws_s3_bucket.bucket`
    This is required to host the site.
- `aws_s3_bucket_policy.bucket_policy`
    This defines the access policy for the Cloudfront distribution.
- `aws_cloudfront_distribution.distribution`
    This is required to enable HTTPS.
- `aws_cloudfront_origin_access_control.access_control`
    This defines the routing rules for the origin on the distibution.
- `aws_cloudfront_function.function`
    This enables serving an `index.html` file at the root of a directory URL as that URL, e.g. https://www.example.com/users/index.html is served as https://www.example.com/users/.
- `aws_route53_record.cname`
    This enables DNS lookup of the site.
- `aws_route53_record.a` (optional, if `redirectable_domains` are supplied)
    This enables apex redirection to another subdomain if desired, e.g. https://example.com/ -> https://www.example.com/

This module depends on these AWS resources existing:

- An AWS account (`data.aws_caller_identity.account`).
- A validated AWS ACM certificate (`data.aws_acm_certificate.certificate`)
    This is required for HTTPS.
- A domain in an AWS Route53 hosted zone data (`data.aws_route53_zone.zone`).
