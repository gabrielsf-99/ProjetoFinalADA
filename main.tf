provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_iam_role" "lambda_enviar_mensagem" {
  name               = "lambda-enviar-mensagem"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "lambda-s3-access-policy"
  role = aws_iam_role.lambda_enviar_mensagem.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = [
          aws_s3_bucket.lambda_bucket.arn,
          "${aws_s3_bucket.lambda_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_enviar_mensagem
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_enviar_mensagem.arn
  handler       = "enviar_mensagem.lambda_handler"
  filename      = "${path.module}/lambda/enviar_mensagem.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/enviar_mensagem.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.sns_topic.arn
    }
  }
}

resource "aws_sns_topic" "sns_topic" {
  name = var.sns_topic_name
}

resource "aws_sqs_queue" "sqs_queue" {
  name = var.sqs_queue_name
  visibility_timeout_seconds = 30
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.sqs_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.sqs_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn": aws_sns_topic.sns_topic.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "sns_to_sqs" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs_queue.arn
}

resource "aws_sns_topic_subscription" "sns_email_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"           # Tipo de assinatura
  endpoint  = "souzafonseca.gsf@gmail.com"
}

resource "aws_s3_bucket_notification" "s3_notification" {
  bucket = aws_s3_bucket.lambda_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "s3.amazonaws.com"

  source_arn = aws_s3_bucket.lambda_bucket.arn
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 14 # Configure a retenção desejada
}

resource "aws_iam_policy" "allow_put_retention_policy" {
  name        = "AllowPutRetentionPolicy"
  description = "Permite definir a política de retenção nos grupos de logs do Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "logs:PutRetentionPolicy",
        Resource = "arn:aws:logs:us-east-1:117793179715:log-group:/aws/lambda/lambda-criar-arquivo:*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_retention_policy" {
  user       = "usuario-ada-contabilidade"
  policy_arn = aws_iam_policy.allow_put_retention_policy.arn
}

resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "lambda-sns-publish-policy"
  role = aws_iam_role.lambda_enviar_mensagem.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = "arn:aws:sns:us-east-1:117793179715:sns-ada-contabilidade"
      }
    ]
  })
}
