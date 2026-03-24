# 개발 환경 변수 값
# 개발 환경은 작은 인스턴스와 작은 CIDR 블록 사용

environment = "dev"
project     = "terraform-example"

# 네트워크 설정 - 개발 환경용 작은 CIDR
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.11.0/24"
availability_zone   = "ap-northeast-2a"

# EC2 설정 - 개발 환경용 작은 인스턴스
instance_type = "t3.micro"
ami_id        = "ami-0c9c942bd7bf113a2" # Amazon Linux 2023 (ap-northeast-2)

# S3 설정
bucket_name = "terraform-example-dev-bucket"

# 태그
tags = {
  Environment = "dev"
  Project     = "terraform-example"
  ManagedBy   = "terraform"
}
