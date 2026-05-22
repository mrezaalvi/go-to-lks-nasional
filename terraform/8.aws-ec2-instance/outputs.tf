output "instance_id" {
  description = "ID dari EC2 instance"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "Public IP instance (jika tersedia)"
  value       = aws_instance.main.public_ip
}

output "private_ip" {
  description = "Private IP instance"
  value       = aws_instance.main.private_ip
}

output "ami_used" {
  description = "AMI ID yang digunakan"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "ami_name" {
  description = "Nama AMI yang digunakan"
  value       = data.aws_ami.amazon_linux_2023.name
}
