output "public_ip" {
  description = "O IP público da instância do Snipe-IT"
  value       = aws_instance.snipeit_server.public_ip
}

output "url" {
  description = "A URL de acesso ao Snipe-IT"
  value       = "http://${aws_instance.snipeit_server.public_ip}"
}
