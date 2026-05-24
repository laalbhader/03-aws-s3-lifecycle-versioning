# =============================================================================
# SECTION: IAM DEPLOYMENT IDENTITY PROVISIONING
# PURPOSE: Establishes a dedicated, isolated IAM User account tailored solely 
#          for continuous delivery automation and automated site synchronization.
# =============================================================================

# 1. Create IAM User
resource "aws_iam_user" "deployer" {
  name = var.iam_user_name
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
# PURPOSE: Attaches specialized read/write policies to the pipeline operator,
#          restricting access only to the targeted production S3 infrastructure.
# =============================================================================

# 3. Attach Custom S3 Policy to IAM User
resource "aws_iam_user_policy" "s3_policy" {
  name = "S3DeployPolicy"
  user = aws_iam_user.deployer.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}