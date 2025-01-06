output "s3_tf_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.s3_tf.arn
}
