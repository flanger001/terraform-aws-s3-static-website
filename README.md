# Static Website

This module creates the infrastructure for a static website hosted on AWS S3 behind a Cloudfront distribution with HTTPS and HTTP-to-HTTPS redirection. 
All routing is through Cloudfront, and as such this does not use the S3 Static Website configuration.

Input variables are documented in [`variables.tf`](variables.tf).

This module will create these AWS resources:

aws_route53_record.aliases
- `aws_s3_bucket.bucket`
    This is required to host the site.
- `aws_s3_bucket_policy.bucket_policy`
    This defines the access policy for the Cloudfront distribution.
- `aws_cloudfront_distribution.distribution`
    This is required to enable HTTPS.
- `aws_cloudfront_origin_access_control.access_control`
    This defines the routing rules for the origin on the distibution.
- `aws_cloudfront_function.function`
    This enables serving an `index.html` file at the root of a directory URL as that URL (e.g. https://www.example.com/users/index.html is served as https://www.example.com/users/), as well as subdomain redirection.
- `aws_route53_record.records`
    This enables DNS lookup of the site.
- `aws_route53_record.aliases` (optional, if `var.domains` contains the TLD of the site)
    This enables apex redirection to another subdomain if desired, e.g. https://example.com/ -> https://www.example.com/

This module depends on these AWS resources existing:

- An AWS account (`data.aws_caller_identity.account`).
- A validated AWS ACM certificate (`data.aws_acm_certificate.certificate`)
    This is required for HTTPS.
- A domain in an AWS Route53 hosted zone for each top-level domain you intend to use (`data.aws_route53_zone.zones`).

## A note on tags

In previous versions of this, there was a `local` variable `tags` that created 3 tags: 

```terraform
tags = {
  Executor = "Terraform"
  ApplicationType = "S3 static website"
  ApplicationHost = "AWS"
}
```

These were added to the `aws_s3_bucket.bucket` and `aws_cloudfront_distribution.distribution` resources, and merged with the `var.application` tag.
The `local` variable is now gone. The `var.application` tag remains and will continue to tag these resources.
To replace the tags previously supplied with `local`, simply provide a `default_tags` configuration with your `aws` provider.
