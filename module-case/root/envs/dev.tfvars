# 개발 환경 변수 설정

environment = "dev"
region      = "ap-northeast-2"
project     = "terraform-example"

# 네트워킹 설정
vpc_cidr     = "10.0.0.0/16"
subnet_count = 2

# 컴퓨트 설정
ami_id        = "ami-0c9c942bd7bf113a2" # Amazon Linux 2023 (ap-northeast-2)
instance_type = "t3.micro"

# S3 버킷 설정
bucket_name       = "dev-terraform-example-bucket-12345"
enable_versioning = true

# 공통 태그
common_tags = {
  Environment = "dev"
  Project     = "terraform-example"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
}
