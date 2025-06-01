<<<<<<< HEAD
output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "rds_sg_id" {
  value = aws_security_group.this.id
}

output "rds_identifier" {
  value = aws_db_instance.this.id
}
=======
output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "rds_sg_id" {
  value = aws_security_group.this.id
}

output "rds_identifier" {
  value = aws_db_instance.this.id
}
>>>>>>> 101118e (fix: refactor directort)
