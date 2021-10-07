output "server_dns" {
  value = aws_instance.mongodb-server.public_dns
}

output "server_public_ip" {
  value = aws_instance.mongodb-server.public_ip
}
