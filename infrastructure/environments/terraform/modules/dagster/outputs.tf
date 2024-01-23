output "database_subnet_group" {
  description = "Subnet Group for the database"
  value       = aws_db_subnet_group.database_subnet_group.id
}

output "database_subnets" {
  description = "A list of the database subnets"
  value       = join(",", [aws_subnet.database_subnet_1.id, aws_subnet.database_subnet_2.id])
}