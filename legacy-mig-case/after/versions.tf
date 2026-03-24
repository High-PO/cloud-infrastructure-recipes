# 테라폼 및 프로바이더 버전 고정
# 마이그레이션 후: 버전 제약을 전용 파일로 분리하여 관리

terraform {
  # 테라폼 최소 버전 요구사항
  required_version = ">= 1.0.0"

  # 필수 프로바이더 및 버전 고정
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }
}
