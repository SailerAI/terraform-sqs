output "queue_id" {
  description = "O ID da fila SQS."
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "O ARN da fila SQS."
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "O nome completo da fila SQS."
  value       = aws_sqs_queue.this.name
}