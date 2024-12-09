import boto3
import os
import re
from urllib.parse import unquote_plus

def lambda_handler(event, context):
    # Inicializa o cliente SNS
    sns = boto3.client('sns')

    # Tópico SNS
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']

    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']

        # Decodifica o nome do arquivo
        decoded_key = unquote_plus(object_key)

        # Extrai o número de linhas do nome do arquivo
        match = re.search(r"arquivo\(\d+\)_(\d+)\.txt", decoded_key)
        if match:
            line_count = int(match.group(1))
        else:
            line_count = "desconhecido"

        # Monta a mensagem
        mensagem = f"O arquivo '{decoded_key}' possui {line_count} linhas e foi adicionado ao bucket '{bucket_name}' com sucesso!"

        # Publica a mensagem no SNS
        sns.publish(
            TopicArn=sns_topic_arn,
            Message=mensagem,
            Subject="Novo arquivo no S3"
        )
        print(f"Mensagem enviada: {mensagem}")

    return {"statusCode": 200, "body": "Mensagem publicada com sucesso"}

