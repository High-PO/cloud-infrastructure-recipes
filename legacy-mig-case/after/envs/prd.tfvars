# 프로덕션 환경 변수 값
# 프로덕션 환경은 큰 인스턴스와 넓은 CIDR 블록 사용

environment = "prd"
project     = "terraform-example"

# 네트워크 설정 - 프로덕션 환경용 넓은 CIDR
vpc_cidr            = "10.2.0.0/16"
public_subnet_cidr  = "10.2.1.0/24"
private_subnet_cidr = "10.2.11.0/24"
availability_zone   = "ap-northeast-2c"

# EC2 설정 - 프로덕션 환경용 큰 인스턴스
instance_type = "t3.medium"
ami_id        = "ami-0c9c942bd7bf113a2" # Amazon Linux 2023 (ap-northeast-2)

# S3 설정
bucket_name = "terraform-example-prd-bucket"

# 태그
tags = {
  Environment = "prd"
  Project     = "terraform-example"
  ManagedBy   = "terraform"
}
