output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.example_vpc.id
}

output "public_subnet_id" {
  description = "The public subnet"
  value       = aws_subnet.example_public_subnet.id
}

output "security_group_id" {
  description = "The private subnet"
  value       = aws_security_group.ingress.id
}

# output "public_ip" {
# description = "The public IP"
# value       = aws_instance.example_public_ip.public_ip
# }

