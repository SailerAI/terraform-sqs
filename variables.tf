variable "project_name" {
  description = "O nome base da fila SQS. Se for uma fila FIFO, '.fifo' será automaticamente anexado."
  type        = string
}

variable "environment" {
  description = "O ambiente de deploy (ex: 'dev', 'hml', 'prod'). Usado para determinar o throughput da fila FIFO."
  type        = string
}

variable "is_fifo" {
  description = "Define se esta é uma fila FIFO. Se 'true', '.fifo' é anexado ao nome e atributos FIFO são ativados."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Para filas FIFO, habilita a deduplicação baseada no conteúdo da mensagem. Não tem efeito para filas padrão. O padrão é 'true' se 'is_fifo' for 'true'."
  type        = bool
  default     = true
}

variable "message_retention_seconds" {
  description = "O número de segundos que o Amazon SQS retém uma mensagem. O padrão é 345600 (4 dias). Mínimo de 60 segundos (1 minuto) e máximo de 1209600 segundos (14 dias)."
  type        = number
  default     = 345600
}

variable "visibility_timeout_seconds" {
  description = "O período em que uma mensagem fica invisível para outros consumidores depois de ser entregue. O padrão é 30 segundos. Mínimo de 0 segundos e máximo de 43200 segundos (12 horas)."
  type        = number
  default     = 30
}

variable "delay_seconds" {
  description = "O atraso para a entrega de novas mensagens à fila. O padrão é 0 segundos. Mínimo de 0 segundos e máximo de 900 segundos (15 minutos)."
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "O tamanho máximo de mensagem permitido para a fila, em bytes. O padrão é 262144 (256 KB). Mínimo de 1024 bytes (1 KB) e máximo de 262144 bytes (256 KB)."
  type        = number
  default     = 262144
}

variable "receive_wait_time_seconds" {
  description = "O tempo de espera para que uma mensagem fique disponível na fila após uma solicitação de recebimento, em segundos. O padrão é 0 segundos. Mínimo de 0 segundos e máximo de 20 segundos."
  type        = number
  default     = 0
}

variable "sqs_managed_sse_enabled" {
  description = "Habilita a criptografia do lado do servidor (SSE) gerenciada pelo SQS (SQS-managed SSE)."
  type        = bool
  default     = true
}

variable "dead_letter_queue_enabled" {
  description = "Define se uma Dead-Letter Queue (DLQ) deve ser configurada para esta fila."
  type        = bool
  default     = false
}

variable "dead_letter_queue_arn" {
  description = "O ARN da Dead-Letter Queue a ser associada. Obrigatório se 'dead_letter_queue_enabled' for 'true'."
  type        = string
  default     = null
}

variable "dead_letter_queue_max_receive_count" {
  description = "O número de vezes que uma mensagem pode ser recebida antes de ser movida para a Dead-Letter Queue. Obrigatório se 'dead_letter_queue_enabled' for 'true'."
  type        = number
  default     = null
}

variable "tags" {
  description = "Um mapa de tags a serem atribuídas à fila."
  type        = map(string)
  default     = {}
}