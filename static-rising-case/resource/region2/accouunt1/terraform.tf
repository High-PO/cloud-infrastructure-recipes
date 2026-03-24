# 테라폼 버전 및 프로바이더 설정
terraform {
  # 테라폼 버전 고정
  required_version = ">= 1.5.0"

  # 필수 프로바이더 정의
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 백엔드 설정 - 상태 파일 원격 저장
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "static-rising/region2/accouunt1/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

# AWS 프로바이더 설정
provider "aws" {
  region = var.region
}
