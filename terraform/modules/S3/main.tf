resource "aws_s3_bucket" "S3_BUCKET" {
  bucket = var.BUCKET_NAME
  tags = merge(var.COMMON_TAGS, var.TAGS)
  versioning {
    enabled = var.VERSIONING
  }
}
