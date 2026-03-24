# 프로바이더 및 백엔드 설정
# 모듈 케이스: 루트 모듈의 프로바이더와 백엔드 설정

# 테라폼 백엔드 설정
terraform {
  # S3 백엔드 설정 - 상태 파일을 S3에 저장하고 DynamoDB로 잠금 관리
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "module-case/root/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

# AWS 프로바이더 설정 - 리전을 변수로 참조하여 다중 리전 배포 지원
provider "aws" {
  region = var.region
}
