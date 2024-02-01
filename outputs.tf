output "bucket" {
  value = aws_s3_bucket.bucket
}

output "bucket_policy" {
  value = aws_s3_bucket_policy.bucket_policy
}

output "distribution" {
  value = aws_cloudfront_distribution.distribution
}

output "access_control" {
  value = aws_cloudfront_origin_access_control.access_control
}

output "function" {
  value = aws_cloudfront_function.function
}

output "a" {
  value = aws_route53_record.a
}

output "cname" {
  value = aws_route53_record.cname
}
