# 테라폼 설정 및 프로바이더 구성
# 레거시 상태: 프로바이더와 백엔드 설정을 하나의 파일에 관리

# 테라폼 버전 및 백엔드 설정
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }

  # S3 백엔드 설정 - 상태 파일을 S3에 저장하고 DynamoDB로 잠금 관리
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "legacy-mig-case/before/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

# AWS 프로바이더 설정 - 리전을 변수로 참조하여 다중 리전 배포 지원
provider "aws" {
  region = var.region
}
