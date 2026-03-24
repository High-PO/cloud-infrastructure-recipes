# 주요 리소스 속성 출력
# 마이그레이션 후: 다른 테라폼 모듈이나 외부 시스템에서 참조할 수 있도록 주요 리소스 정보 출력

# VPC 출력
output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC의 CIDR 블록"
  value       = aws_vpc.main.cidr_block
}

# 서브넷 출력
output "public_subnet_id" {
  description = "퍼블릭 서브넷 ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "프라이빗 서브넷 ID"
  value       = aws_subnet.private.id
}

output "subnet_ids" {
  description = "모든 서브넷 ID 목록"
  value       = [aws_subnet.public.id, aws_subnet.private.id]
}

# EC2 출력
output "instance_id" {
  description = "EC2 인스턴스 ID"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "EC2 인스턴스 퍼블릭 IP"
  value       = aws_instance.main.public_ip
}

output "instance_private_ip" {
  description = "EC2 인스턴스 프라이빗 IP"
  value       = aws_instance.main.private_ip
}

output "security_group_id" {
  description = "EC2 보안 그룹 ID"
  value       = aws_security_group.ec2.id
}

# S3 출력
output "s3_bucket_id" {
  description = "S3 버킷 ID (이름)"
  value       = aws_s3_bucket.main.id
}

output "s3_bucket_arn" {
  description = "S3 버킷 ARN"
  value       = aws_s3_bucket.main.arn
}

output "s3_bucket_domain_name" {
  description = "S3 버킷 도메인 이름"
  value       = aws_s3_bucket.main.bucket_domain_name
}

# IAM 출력
output "iam_role_arn" {
  description = "EC2 IAM 역할 ARN"
  value       = aws_iam_role.ec2_role.arn
}

output "iam_role_name" {
  description = "EC2 IAM 역할 이름"
  value       = aws_iam_role.ec2_role.name
}

output "iam_instance_profile_arn" {
  description = "EC2 인스턴스 프로파일 ARN"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "iam_policy_arn" {
  description = "S3 읽기 정책 ARN"
  value       = aws_iam_policy.s3_read_policy.arn
}
