# =============================================================================
# SECTION: IAM DEPLOYMENT IDENTITY PROVISIONING
# PURPOSE: Establishes a dedicated, isolated IAM User account tailored solely 
#          for continuous delivery automation and automated site synchronization
#          with explicit force-destruction flags enabled.
# =============================================================================

# 1. Create IAM User
resource "aws_iam_user" "deployer" {
  name          = var.iam_user_name
  force_destroy = true # Forces deletion of associated manual resources during destroy
}


# =============================================================================
# SECTION: AUTOMATION RUNTIME SECURE CREDENTIALS
# PURPOSE: Generates cryptographically secure API keys to authenticate the 
#          deployment entity during remote CI/CD automation procedures.
# =============================================================================

# 2. Create IAM Access Keys for User
resource "aws_iam_access_key" "deployer_keys" {
  user = aws_iam_user.deployer.name
}


# =============================================================================
# SECTION: LEAST-PRIVILEGE AUTHORIZATION POLICY
# PURPOSE: Attaches specialized read/write and cache purge policies to the 
#          pipeline operator, restricting access only to required target assets.
# =============================================================================

# 3. Attach Custom S3 and CloudFront Policy to IAM User
resource "aws_iam_user_policy" "s3_policy" {
  name = "S3DeployPolicy"
  user = aws_iam_user.deployer.name

  # یہاں ہم نے مینوئل سٹرنگ کی جگہ ڈائریکٹ ٹیرارفارم ریسورس ریفرنس استعمال کیا ہے
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"]
        Resource = [
          "${aws_s3_bucket.static_site.arn}",
          "${aws_s3_bucket.static_site.arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = "*"
      }
    ]
  })
}


# =============================================================================
# SECTION: AUTOMATION PIPELINE OUTPUT EXPOSURE
# PURPOSE: Exports generated credential strings required to securely configure
#          encrypted environment secrets within the remote GitHub Actions vault.
# =============================================================================

# 4. Export Access Key ID for GitHub Secrets configuration
output "aws_access_key_id" {
  value       = aws_iam_access_key.deployer_keys.id
  sensitive   = false
  description = "The Access Key ID for the deployment pipeline service account"
}

# 5. Export Secret Access Key for GitHub Secrets configuration
output "aws_secret_access_key" {
  value       = aws_iam_access_key.deployer_keys.secret
  sensitive   = true
  description = "The Secret Access Key for the deployment pipeline service account"
}