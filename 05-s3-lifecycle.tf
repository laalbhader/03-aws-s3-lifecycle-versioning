# =========================================================================
# SECTION: DATA RESILIENCE & DISASTER RECOVERY
# PURPOSE: Enables bucket versioning to protect against accidental deletions
#          and allow instant rollbacks to previous stable versions.
# =========================================================================

resource "aws_s3_bucket_versioning" "website_versioning" {
  bucket = aws_s3_bucket.static_site.id # آپ کی اصل بکٹ کا ٹیرافارم ریسورس نام

  versioning_configuration {
    status = "Enabled"
  }
}



# =========================================================================
# SECTION: COST OPTIMIZATION & AUTOMATED LIFECYCLE MANAGEMENT
# PURPOSE: Automatically purges noncurrent versions after 30 days and 
#          cleans up incomplete multipart uploads to minimize AWS costs.
# =========================================================================

resource "aws_s3_bucket_lifecycle_configuration" "website_lifecycle" {
  bucket = aws_s3_bucket.static_site.id

  rule {
    id     = "cleanup-old-website-versions"
    status = "Enabled"

    # پرانے ورژنز (Noncurrent Versions) کو 30 دن بعد مستقل ڈیلیٹ کرنے کا رول
    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    # اگر کوئی فائل اپلوڈ ہوتے ہوئے بیچ میں رک جائے، تو 7 دن بعد اس کا کچرا صاف کر دو
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}