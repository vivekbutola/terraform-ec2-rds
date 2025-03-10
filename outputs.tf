# Output the EC2 instance public IP (if applicable, but it's in a private subnet)
output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.ec2_instance.id
}

output "ec2_private_ip" {
  description = "The private IP of the EC2 instance"
  value       = aws_instance.ec2_instance.private_ip
}

# Output the VPC ID
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.terraform_vpc.id
}

# Output the Private Subnet IDs
output "private_subnet_1_id" {
  description = "The ID of the first private subnet"
  value       = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  description = "The ID of the second private subnet"
  value       = aws_subnet.private_subnet_2.id
}

# Output RDS Instance Details
output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.terraform_rds.id
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.terraform_rds.endpoint
}

# Output Security Group IDs
output "ec2_security_group_id" {
  description = "The ID of the security group assigned to EC2"
  value       = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  description = "The ID of the security group assigned to RDS"
  value       = aws_security_group.rds_sg.id
}

# Output S3 Bucket Name
output "s3_bucket_name" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.terraform_bucket.id
}
