# terraform-sqs
SQS terraform module 


# Módulo Terraform para AWS SQS Queue

Este módulo Terraform permite criar e gerenciar filas Amazon Simple Queue Service (SQS) na AWS, com suporte a filas padrão (Standard) e FIFO (First-In, First-Out), incluindo configurações de High-Throughput para ambientes de produção.

## ✨ Funcionalidades

*   Criação de filas SQS padrão ou FIFO.
*   Nomenclatura automática da fila com base no nome do projeto e ambiente (ex: `meuprojeto-dev`, `meuprojeto-prod.fifo`).
*   Configuração de filas FIFO com throughput padrão (para HML) ou High-Throughput (`perMessageGroupId`) para Produção.
*   Opção para habilitar deduplicação baseada em conteúdo para filas FIFO.
*   Configuração de Dead-Letter Queues (DLQ) para reprocessamento de mensagens falhas.
*   Definição de parâmetros da fila como tempo de retenção de mensagens, visibilidade, atraso, tamanho máximo de mensagem e tempo de espera.
*   Habilitação de SQS-Managed Server-Side Encryption (SSE).
*   Adição de tags personalizadas.

## 🚀 Como Usar

Para utilizar este módulo, inclua-o em seu projeto Terraform e configure as variáveis conforme suas necessidades.

### Estrutura do Projeto

Certifique-se de que seu módulo esteja na seguinte estrutura (ou ajuste o `source` conforme necessário):

```
.
├── main.tf             # Seu arquivo Terraform principal
├── variables.tf        # Suas variáveis globais
└── modules/
    └── sqs_queue/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Exemplo de Uso:

#### 1. Fila SQS Padrão (Não-FIFO)

Cria uma fila SQS padrão para um ambiente de desenvolvimento.

```terraform
module "standard_queue_dev" {
  source = "./modules/sqs_queue" # Caminho para o seu módulo

  project_name = "my-app"
  environment  = "dev"
  is_fifo      = false # Fila padrão

  message_retention_seconds = 86400 # 1 dia
  tags = {
    "Owner" = "DevTeam"
    "CostCenter" = "12345"
  }
}
```

**Nome da fila gerado:** `my-app-dev`

#### 2. Fila SQS FIFO para HML (Throughput Padrão)

Cria uma fila SQS FIFO para um ambiente de homologação, utilizando o throughput padrão para FIFO (`perQueue`).

```terraform
module "fifo_queue_hml" {
  source = "./modules/sqs_queue"

  project_name = "my-app"
  environment  = "hml" # Ambiente HML
  is_fifo      = true  # Fila FIFO

  content_based_deduplication = true # Habilita deduplicação
  message_retention_seconds   = 172800 # 2 dias

  tags = {
    "Owner" = "QA"
    "CostCenter" = "12345"
  }
}
```

**Nome da fila gerado:** `my-app-hml.fifo`

#### 3. Fila SQS FIFO para Produção (High-Throughput com DLQ)

Cria uma fila SQS FIFO para um ambiente de produção, configurando-a para High-Throughput (`perMessageGroupId`) e associando uma Dead-Letter Queue (DLQ).

```terraform
# Primeiro, crie a Dead-Letter Queue (DLQ)
resource "aws_sqs_queue" "fifo_queue_prod_dlq" {
  name                        = "my-app-prod-dlq.fifo" # Nome manual para a DLQ
  fifo_queue                  = true
  content_based_deduplication = false # DLQ geralmente não precisa de deduplicação por conteúdo
  message_retention_seconds   = 604800 # 7 dias

  tags = {
    "Project"     = "my-app"
    "Environment" = "prod"
    "Type"        = "DLQ"
  }
}

# Em seguida, crie a fila principal utilizando a DLQ
module "fifo_queue_prod" {
  source = "./modules/sqs_queue"

  project_name = "my-app"
  environment  = "prod" # Ambiente de Produção
  is_fifo      = true   # Fila FIFO

  content_based_deduplication = true # Habilita deduplicação
  message_retention_seconds   = 604800 # 7 dias
  visibility_timeout_seconds  = 60

  # Configuração da Dead-Letter Queue
  dead_letter_queue_enabled         = true
  dead_letter_queue_arn             = aws_sqs_queue.fifo_queue_prod_dlq.arn
  dead_letter_queue_max_receive_count = 5 # Recebe 5 vezes antes de ir para a DLQ

  tags = {
    "Owner" = "Operations"
    "CostCenter" = "12345"
  }
}
```

**Nome da fila principal gerado:** `my-app-prod.fifo`
**Nome da DLQ gerado:** `my-app-prod-dlq.fifo`

## ⚙️ Variáveis (Inputs)

| Nome                                | Descrição                                                                                                                                              | Tipo    | Padrão     | Obrigatório |
| :---------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------- | :------ | :--------- | :---------- |
| `project_name`                      | O nome do projeto ou aplicação que a fila SQS pertence. Será parte do nome final da fila (ex: 'myproject').                                            | `string` | n/a        | sim         |
| `environment`                       | O ambiente de deploy (ex: 'dev', 'hml', 'prod'). Usado para formar o nome da fila e determinar o throughput da fila FIFO.                               | `string` | n/a        | sim         |
| `is_fifo`                           | Define se esta é uma fila FIFO. Se 'true', '.fifo' é anexado ao nome e atributos FIFO são ativados.                                                   | `bool`  | `false`    | não         |
| `content_based_deduplication`       | Para filas FIFO, habilita a deduplicação baseada no conteúdo da mensagem. Não tem efeito para filas padrão. O padrão é 'true' se 'is_fifo' for 'true'. | `bool`  | `true`     | não         |
| `message_retention_seconds`         | O número de segundos que o Amazon SQS retém uma mensagem. Mínimo de 60 segundos (1 minuto) e máximo de 1209600 segundos (14 dias).                   | `number` | `345600`   | não         |
| `visibility_timeout_seconds`        | O período em que uma mensagem fica invisível para outros consumidores depois de ser entregue. Mínimo de 0 segundos e máximo de 43200 segundos (12 horas). | `number` | `30`       | não         |
| `delay_seconds`                     | O atraso para a entrega de novas mensagens à fila. Mínimo de 0 segundos e máximo de 900 segundos (15 minutos).                                        | `number` | `0`        | não         |
| `max_message_size`                  | O tamanho máximo de mensagem permitido para a fila, em bytes. Mínimo de 1024 bytes (1 KB) e máximo de 262144 bytes (256 KB).                          | `number` | `262144`   | não         |
| `receive_wait_time_seconds`         | O tempo de espera para que uma mensagem fique disponível na fila após uma solicitação de recebimento, em segundos. Mínimo de 0 segundos e máximo de 20 segundos. | `number` | `0`        | não         |
| `sqs_managed_sse_enabled`           | Habilita a criptografia do lado do servidor (SSE) gerenciada pelo SQS (SQS-managed SSE).                                                              | `bool`  | `true`     | não         |
| `dead_letter_queue_enabled`         | Define se uma Dead-Letter Queue (DLQ) deve ser configurada para esta fila.                                                                             | `bool`  | `false`    | não         |
| `dead_letter_queue_arn`             | O ARN da Dead-Letter Queue a ser associada. Obrigatório se 'dead_letter_queue_enabled' for 'true'.                                                    | `string` | `null`     | não         |
| `dead_letter_queue_max_receive_count` | O número de vezes que uma mensagem pode ser recebida antes de ser movida para a Dead-Letter Queue. Obrigatório se 'dead_letter_queue_enabled' for 'true'. | `number` | `null`     | não         |
| `tags`                              | Um mapa de tags adicionais a serem atribuídas à fila.                                                                                                  | `map(string)` | `{}`       | não         |

## 📤 Saídas (Outputs)

| Nome        | Descrição                       |
| :---------- | :------------------------------ |
| `queue_id`  | O ID da fila SQS.               |
| `queue_arn` | O ARN (Amazon Resource Name) da fila SQS. |
| `queue_name`| O nome completo da fila SQS.    |

## �� Requisitos

Este módulo requer:

*   Terraform `~> 1.0`
*   AWS Provider `~> 5.0`

## 🤝 Contribuições

Contribuições são bem-vindas! Por favor, abra um *issue* ou *pull request* no repositório.

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---