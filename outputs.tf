output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.lambda_bucket.bucket
}
