# networking 모듈 출력 값 정의

output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "생성된 모든 서브넷의 ID 목록"
  value       = aws_subnet.public[*].id
}

output "public_subnet_ids" {
  description = "생성된 퍼블릭 서브넷의 ID 목록"
  value       = aws_subnet.public[*].id
}

output "vpc_cidr_block" {
  description = "VPC의 CIDR 블록"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "인터넷 게이트웨이 ID"
  value       = aws_internet_gateway.main.id
}
