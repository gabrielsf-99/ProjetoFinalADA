output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.lambda_bucket.bucket
}

output "sns_topic_arn" {
  value = aws_sns_topic.sns_topic.arn
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.sqs_queue.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.sqs_queue.id
}