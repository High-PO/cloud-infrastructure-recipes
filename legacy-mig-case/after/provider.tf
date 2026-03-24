# 프로바이더 및 백엔드 설정
# 마이그레이션 후: 프로바이더와 백엔드 설정을 전용 파일로 분리하여 관리

# 테라폼 백엔드 설정
terraform {
  # S3 백엔드 설정 - 상태 파일을 S3에 저장하고 DynamoDB로 잠금 관리
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "legacy-mig-case/after/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

# AWS 프로바이더 설정 - 리전을 변수로 참조하여 다중 리전 배포 지원
provider "aws" {
  region = var.region
}
