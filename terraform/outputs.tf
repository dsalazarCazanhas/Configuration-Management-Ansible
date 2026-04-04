output "instance_public_dns" {
  description = "Public DNS of the EC2 instance — use this in inventory.ini"
  value       = aws_instance.app_server.public_dns
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
