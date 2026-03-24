# compute 모듈 출력 값 정의

output "instance_id" {
  description = "생성된 EC2 인스턴스의 ID"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "EC2 인스턴스의 퍼블릭 IP 주소"
  value       = aws_instance.main.public_ip
}

output "security_group_id" {
  description = "생성된 보안 그룹의 ID"
  value       = aws_security_group.instance.id
}

output "private_ip" {
  description = "EC2 인스턴스의 프라이빗 IP 주소"
  value       = aws_instance.main.private_ip
}
