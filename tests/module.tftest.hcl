provider "aws" {
  region  = "us-east-1"
  profile = "current"
}

run "creates_infrastructure" {
  command = apply

  variables {
    bucket_name              = "flanger001-bucket-${substr(uuid(), 0, 13)}"
    certificate_name         = "daveshaffer.com"
    cloudfront_function_name = "Flanger001-function-${substr(uuid(), 0, 13)}"
    domains                  = ["${substr(uuid(), 0, 13)}.daveshaffer.com"]
    primary_domain           = "daveshaffer.com"
  }

  assert {
    condition     = aws_s3_bucket.bucket.bucket == var.bucket_name
    error_message = "Bucket did not persist name"
  }

  assert {
    condition = jsondecode(aws_s3_bucket_policy.bucket_policy.policy)["Statement"][0]["Condition"] == {
      StringEquals = {
        "AWS:SourceArn" = aws_cloudfront_distribution.distribution.arn
      }
    }
    error_message = "Bucket policy does not reference Cloudfront distribution"
  }

  assert {
    condition = contains(
      aws_cloudfront_distribution.distribution.origin[*].origin_access_control_id,
      aws_cloudfront_origin_access_control.access_control.id
    )
    error_message = "Cloudfront origin access control not linked to Cloudfront distribution"
  }

  assert {
    condition     = aws_cloudfront_function.function.runtime == "cloudfront-js-2.0"
    error_message = "Runtime is not equal to \"cloudfront-js-2.0\""
  }

  assert {
    condition = contains(
      aws_route53_record.records["daveshaffer.com_${var.domains[0]}_CNAME"].records,
      aws_cloudfront_distribution.distribution.domain_name
    )
    error_message = "Route53 record value does not match Cloudfront distribution domain name"
  }
}

run "separates_a_records" {
  command = plan

  variables {
    bucket_name              = "flanger001-bucket-${substr(uuid(), 0, 13)}"
    certificate_name         = "daveshaffer.com"
    cloudfront_function_name = "Flanger001-function-${substr(uuid(), 0, 13)}"
    domains = [
      "daveshaffer.co",
      "daveshaffer.com",
      "www.daveshaffer.co",
      "www.daveshaffer.com"
    ]
    primary_domain = "www.daveshaffer.com"
  }

  assert {
    condition     = length(aws_route53_record.aliases) == 2
    error_message = "Too many aliases"
  }
}

run "does_not_output_redirect_section_unnecessarily" {
  command = plan

  variables {
    bucket_name              = "flanger001-bucket-${substr(uuid(), 0, 13)}"
    certificate_name         = "daveshaffer.com"
    cloudfront_function_name = "Flanger001-function-${substr(uuid(), 0, 13)}"
    domains                  = ["test.daveshaffer.com"]
    primary_domain           = "test.daveshaffer.com"
  }

  assert {
    condition     = !strcontains(aws_cloudfront_function.function.code, "hostIsRedirectable")
    error_message = "Function redirect section should not be written if there are no redirects"
  }
}
