import boto3
import os

def lambda_handler(event, context):
    # Cliente S3
    s3 = boto3.client('s3')

    # Bucket e arquivo
    bucket_name = os.environ['BUCKET_NAME']
    file_name = "output.txt"
    content = "Este é um arquivo gerado pela função Lambda."

    try:
        # Enviar arquivo para o S3
        s3.put_object(Bucket=bucket_name, Key=file_name, Body=content)
        return {"statusCode": 200, "body": f"Arquivo {file_name} criado no bucket {bucket_name}"}
    except Exception as e:
        return {"statusCode": 500, "body": str(e)}
