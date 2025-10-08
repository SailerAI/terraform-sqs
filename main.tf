resource "aws_sqs_queue" "this" {
  name                        = "${format("%s-%s", var.project_name, var.environment)}${var.is_fifo ? ".fifo" : ""}"
  fifo_queue                  = var.is_fifo
  content_based_deduplication = var.is_fifo ? var.content_based_deduplication : null
  # Para filas FIFO de alto throughput em ambiente de Produção, definimos "perMessageGroupId".
  # Para outros ambientes FIFO (como HML), omitimos este atributo para usar o padrão "perQueue" (throughput padrão).
  # Para filas não-FIFO, o atributo não é aplicável e será nulo.
  fifo_throughput_limit = var.is_fifo && var.environment == "prod" ? "perMessageGroupId" : null

  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  sqs_managed_sse_enabled    = var.sqs_managed_sse_enabled

  # Configuração de Dead Letter Queue (DLQ)
  redrive_policy = var.dead_letter_queue_enabled ? jsonencode({
    deadLetterTargetArn = var.dead_letter_queue_arn
    maxReceiveCount     = var.dead_letter_queue_max_receive_count
  }) : null

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
