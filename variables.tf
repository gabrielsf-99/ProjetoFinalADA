variable "aws_region" {
  default = "us-east-1"
}

variable "s3_bucket_name" {
  default = "s3-ada-contabilidade"
}

variable "lambda_criar_arquivo" {
  default = "lambda-criar-arquivo"
}

variable "sns_topic_name" {
  default     = "sns-ada-contabilidade"
}

variable "sqs_queue_name" {
  default     = "sqs-ada-contabilidade"
}
