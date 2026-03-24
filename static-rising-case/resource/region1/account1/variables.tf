# 리전/계정별 변수 정의

variable "region" {
  type        = string
  description = "AWS 리전"
  default     = "ap-northeast-2"
}

variable "environment" {
  type        = string
  description = "배포 환경 (dev, stg, prd)"
  default     = "prd"
}

variable "account" {
  type        = string
  description = "계정 식별자"
  default     = "account1"
}

variable "project" {
  type        = string
  description = "프로젝트 이름"
  default     = "terraform-examples"
}
