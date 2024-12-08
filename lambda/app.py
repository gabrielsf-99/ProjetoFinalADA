import boto3
import random
import os
import re

def obter_proximo_numero(bucket_name, prefixo="arquivo"):

    s3 = boto3.client('s3')
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefixo)
    arquivos = response.get('Contents', [])
    
    numeros = []
    for obj in arquivos:
        match = re.search(r"arquivo\((\d+)\)_", obj['Key'])
        if match:
            numeros.append(int(match.group(1)))

    return max(numeros, default=0) + 1

def gerar_numeros_e_criar_arquivo(numero, arquivo_local):

    with open(arquivo_local, 'w') as f:
        for i in range(1, numero + 1):
            f.write(f"{i}\n")
    print(f"Arquivo '{arquivo_local}' gerado com números de 1 a {numero}.")

def enviar_para_s3(bucket_name, arquivo_local, arquivo_s3):

    s3 = boto3.client('s3')
    try:
        s3.upload_file(arquivo_local, bucket_name, arquivo_s3)
        print(f"Arquivo '{arquivo_local}' enviado para o bucket '{bucket_name}' como '{arquivo_s3}'.")
    except Exception as e:
        print(f"Erro ao enviar arquivo para o S3: {e}")

def main():
    # Configurações
    bucket_name = "s3-ada-contabilidade"
    prefixo = "arquivo"

    numero_aleatorio = random.randint(1, 100)

    proximo_numero = obter_proximo_numero(bucket_name, prefixo)

    arquivo_local = f"arquivo({proximo_numero})_{numero_aleatorio}.txt"
    arquivo_s3 = f"arquivo({proximo_numero})_{numero_aleatorio}.txt"

    gerar_numeros_e_criar_arquivo(numero_aleatorio, arquivo_local)

    enviar_para_s3(bucket_name, arquivo_local, arquivo_s3)

    if os.path.exists(arquivo_local):
        os.remove(arquivo_local)
        print(f"Arquivo local '{arquivo_local}' removido.")

if __name__ == "__main__":
    main()

