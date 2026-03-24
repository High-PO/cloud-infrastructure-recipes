# 출력 정의

# VPC 출력
output "vpc_ids" {
  description = "생성된 VPC ID 맵"
  value       = { for k, v in aws_vpc.this : k => v.id }
}

output "vpc_cidr_blocks" {
  description = "VPC CIDR 블록 맵"
  value       = { for k, v in aws_vpc.this : k => v.cidr_block }
}

# 서브넷 출력
output "subnet_ids" {
  description = "생성된 서브넷 ID 맵"
  value       = { for k, v in aws_subnet.this : k => v.id }
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 리스트"
  value = [
    for k, v in aws_subnet.this : v.id
    if v.map_public_ip_on_launch
  ]
}

output "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 리스트"
  value = [
    for k, v in aws_subnet.this : v.id
    if !v.map_public_ip_on_launch
  ]
}

# Internet Gateway 출력
output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

# Security Group 출력
output "security_group_id" {
  description = "웹 서버용 Security Group ID"
  value       = aws_security_group.web.id
}

# 데이터 소스 출력
output "latest_amazon_linux_2_ami" {
  description = "최신 Amazon Linux 2 AMI ID"
  value       = data.aws_ami.amazon_linux_2.id
}

output "available_azs" {
  description = "사용 가능한 가용 영역 리스트"
  value       = data.aws_availability_zones.available.names
}

output "account_id" {
  description = "현재 AWS 계정 ID"
  value       = data.aws_caller_identity.current.account_id
}

output "region_name" {
  description = "현재 AWS 리전 이름"
  value       = data.aws_region.current.name
}
