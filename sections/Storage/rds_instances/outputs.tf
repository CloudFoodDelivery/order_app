output "rds_instance1_endpoint" {
  description = "The endpoint of the first RDS instance"
  value       = aws_db_instance.rds_instance1.endpoint
}

output "rds_instance2_endpoint" {
  description = "The endpoint of the second RDS instance"
  value       = aws_db_instance.rds_instance2.endpoint
}

output "sg_rds_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.sg_rds.id
}
