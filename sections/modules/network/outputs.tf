output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc_fdp.id
}

output "private_db_subnet1_id" {
  description = "The ID of the first private database subnet"
  value       = aws_subnet.private_db_subnet1.id
}

output "private_db_subnet2_id" {
  description = "The ID of the second private database subnet"
  value       = aws_subnet.private_db_subnet2.id
}
