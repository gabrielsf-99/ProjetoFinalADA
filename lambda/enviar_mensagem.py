import boto3
import os
import re

def lambda_handler(event, context):
    sns = boto3.client('sns')

    sns_topic_arn = os.environ['SNS_TOPIC_ARN']

    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']

        match = re.search(r"arquivo\(\d+\)_(\d+)\.txt", object_key)
        if match:
            line_count = int(match.group(1))
        else:
            line_count = "desconhecido"

        mensagem = f"O arquivo '{object_key}' possui {line_count} linhas e foi adicionado ao bucket '{bucket_name}' com sucesso!"

        sns.publish(
            TopicArn=sns_topic_arn,
            Message=mensagem,
            Subject="Novo arquivo adicionado ao S3"
        )
        print(mensagem)

    return {"statusCode": 200, "body": "Processamento concluído."}
