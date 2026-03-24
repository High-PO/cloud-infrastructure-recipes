# 루트 모듈 출력 값 정의
# 각 모듈의 주요 출력 값을 최종 출력으로 노출

# 네트워킹 모듈 출력
output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = module.networking.vpc_id
}

output "subnet_ids" {
  description = "생성된 서브넷의 ID 목록"
  value       = module.networking.subnet_ids
}

output "vpc_cidr_block" {
  description = "VPC의 CIDR 블록"
  value       = module.networking.vpc_cidr_block
}

# 컴퓨트 모듈 출력
output "instance_id" {
  description = "생성된 EC2 인스턴스의 ID"
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "EC2 인스턴스의 퍼블릭 IP 주소"
  value       = module.compute.public_ip
}

output "instance_private_ip" {
  description = "EC2 인스턴스의 프라이빗 IP 주소"
  value       = module.compute.private_ip
}

output "security_group_id" {
  description = "생성된 보안 그룹의 ID"
  value       = module.compute.security_group_id
}

# S3 버킷 모듈 출력
output "s3_bucket_id" {
  description = "생성된 S3 버킷의 ID"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "생성된 S3 버킷의 ARN"
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_region" {
  description = "S3 버킷이 생성된 리전"
  value       = module.s3_bucket.s3_bucket_region
}
