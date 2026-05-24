# =============================================================================
# SECTION: STATIC WEBSITE STORAGE INFRASTRUCTURE
# PURPOSE: Configures the core S3 bucket to host raw static website assets 
#          with explicit naming conventions and resource tracking.
# =============================================================================

# 1. S3 Bucket Creation
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name

  tags = {
    Name = var.project_name
  }
}


# =============================================================================
# SECTION: ORIGIN ACCESS CONTROL (OAC) SECURITY
# PURPOSE: Defines secure authentication parameters for CloudFront to establish
#          trusted, isolated network paths directly into the S3 origin.
# =============================================================================

# Create CloudFront Origin Access Control (OAC) Setup
# 2. Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


# =============================================================================
# SECTION: GLOBAL CONTENT DELIVERY NETWORK (CDN)
# PURPOSE: Provisions edge routing, cache policies, and SSL delivery paths 
#          to speed up content load times globally via AWS CloudFront.
# =============================================================================

# Create Cloudfront Origin Access Control (OAC)
# 3. CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_document

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Project = var.project_name
  }
}


# =============================================================================
# SECTION: EDGE ACQUISITION ACCESS POLICY
# PURPOSE: Modifies S3 bucket access control to exclusively authorize GetObject
#          operations originating from the verified CloudFront OAC identity.
# =============================================================================

# Configure S3 Bucket Policy
# 4. S3 Bucket Policy (OAC کو اجازت دینا)
resource "aws_s3_bucket_policy" "cdn_oac_policy" {
  bucket = aws_s3_bucket.static_site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.static_site.arn}/*"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}