output "cloudfront_url" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "s3_bucket_id" {
  value = aws_s3_bucket.static_site.id
}

output "cloudfront_id" {
  description = "The ID of the CloudFront Distribution"
  value       = aws_cloudfront_distribution.s3_distribution.id
}
output "deployer_access_key" {
  value = aws_iam_access_key.deployer_keys.id
}

output "deployer_secret_key" {
  value     = aws_iam_access_key.deployer_keys.secret
  sensitive = true
}