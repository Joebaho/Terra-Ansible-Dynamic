output "controller_public_ip" {
  value = aws_instance.controller.public_ip
}
output "node_public_ips" {
  value = aws_instance.nodes[*].public_ip
}
