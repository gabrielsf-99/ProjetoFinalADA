provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_iam_role" "lambda_criar_arquivo" {
  name               = "lambda-exec-role"
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
  role = aws_iam_role.lambda_criar_arquivo.id

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
  function_name = var.lambda_criar_arquivo
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_criar_arquivo.arn
  handler       = "criar_arquivo.lambda_handler" 
  filename      = "${path.module}/lambda/criar_arquivo.zip" 
  source_code_hash = filebase64sha256("${path.module}/lambda/criar_arquivo.zip") 

  environment {
    variables = {
      BUCKET_NAME = var.s3_bucket_name
    }
  }
}

