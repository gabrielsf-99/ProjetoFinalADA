
# Projeto Final ADA - Santander Coders 2024-2 - AWS DevOps

## Descrição do Projeto

Este projeto utiliza **Terraform** para criar e gerenciar infraestrutura na AWS. A aplicação inclui os seguintes componentes:

- Um **bucket S3** para armazenar os arquivos.
- Uma **função Lambda** que é acionada quando um novo arquivo é adicionado ao bucket S3.
- A Lambda envia mensagens para um tópico **SNS**, que notifica um endereço de e-mail e publica mensagens em uma fila **SQS**.
- Logs da Lambda são configurados no **CloudWatch**.

---

## Recursos Utilizados

### Tecnologias
- **Terraform**: Para a infraestrutura como código.
- **AWS Lambda**: Função que processa eventos S3 e envia mensagens para o SNS.
- **AWS S3**: Armazenamento de arquivos.
- **AWS SNS**: Envio de notificações por e-mail e integração com o SQS.
- **AWS SQS**: Armazenamento de mensagens publicadas pelo SNS.
- **AWS CloudWatch**: Monitoramento e logs.
- **Python**: Código para a função Lambda.

### Serviços AWS Criados
- **Bucket S3**: `s3-ada-contabilidade`
- **Função Lambda**: `lambda-criar-arquivo`
- **Tópico SNS**: `sns-ada-contabilidade`
- **Fila SQS**: `sqs-ada-contabilidade`
- **Grupo de Logs CloudWatch**

---

## Estrutura do Projeto

```
.
├── main.tf                # Configuração principal do Terraform
├── variables.tf           # Declaração de variáveis
├── outputs.tf             # Outputs para referência
├── lambda/
│   ├── enviar_mensagem.py # Código da função Lambda
│   └── enviar_mensagem.zip # Código empacotado para Lambda
├── README.md              # Este arquivo
```

---

## Como Configurar e Usar

### Pré-requisitos
1. **Terraform** instalado ([Download](https://www.terraform.io/downloads.html)).
2. Credenciais configuradas para a AWS:
   ```bash
   aws configure
   ```
3. Python para criar o arquivo zip para o Lambda.

### Configuração

1. Clone este repositório:
   ```bash
   git clone <url-do-repositorio>
   cd <diretorio-do-projeto>
   ```

2. Inicialize o Terraform:
   ```bash
   terraform init
   ```

3. Edite o arquivo `variables.tf` para definir valores específicos, como:
   - Nome do bucket S3
   - Nome do tópico SNS
   - Nome da fila SQS

4. Crie o arquivo ZIP para a Lambda:
   ```bash
   cd lambda
   zip enviar_mensagem.zip enviar_mensagem.py
   cd ..
   ```

5. Execute o Terraform:
   ```bash
   terraform plan
   terraform apply
   ```

6. Confirme a assinatura de e-mail no SNS (verifique seu e-mail).

### Testando

1. Faça upload de um arquivo no bucket S3:
   ```bash
   aws s3 cp exemplo.txt s3://<seu-bucket-s3>
   ```

2. Verifique o e-mail cadastrado para a notificação.
3. Consulte a fila SQS para verificar mensagens publicadas.

---

## Licença

Este projeto está sob a licença MIT. Sinta-se à vontade para utilizá-lo e modificá-lo conforme necessário.

---

## Autor

**Gabriel Souza Fonseca**

---

## Professora

**Thayse Frankenberger**

---

Se tiver dúvidas ou sugestões, entre em contato! 🚀
