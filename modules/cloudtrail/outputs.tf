output "log_bucket_name" {
  value = aws_s3_bucket.cloudtrail.bucket
}

output "trail_name" {
  value = aws_cloudtrail.main.name
}
