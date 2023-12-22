output "S3_BUCKET" {
  value       = "${aws_s3_bucket.S3_BUCKET}"
  description = "Complete s3 bucket output"
}
output "S3_BUCKET_NAME" {
  value       = "${aws_s3_bucket.S3_BUCKET.id}"
  description = "S3 bucket name"
}
