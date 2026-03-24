# 스테이징 환경 변수 값
# 스테이징 환경은 중간 크기 인스턴스와 CIDR 블록 사용

environment = "stg"
project     = "terraform-example"

# 네트워크 설정 - 스테이징 환경용 중간 CIDR
vpc_cidr            = "10.1.0.0/16"
public_subnet_cidr  = "10.1.1.0/24"
private_subnet_cidr = "10.1.11.0/24"
availability_zone   = "ap-northeast-2a"

# EC2 설정 - 스테이징 환경용 중간 인스턴스
instance_type = "t3.small"
ami_id        = "ami-0c9c942bd7bf113a2" # Amazon Linux 2023 (ap-northeast-2)

# S3 설정
bucket_name = "terraform-example-stg-bucket"

# 태그
tags = {
  Environment = "stg"
  Project     = "terraform-example"
  ManagedBy   = "terraform"
}
