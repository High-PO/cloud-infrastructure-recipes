# networking 모듈 입력 변수 정의

variable "environment" {
  type        = string
  description = "배포 환경 (dev, stg, prd)"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR 블록"
}

variable "subnet_count" {
  type        = number
  description = "생성할 서브넷 개수"
  default     = 2
}

variable "region" {
  type        = string
  description = "AWS 리전"
}

variable "project" {
  type        = string
  description = "프로젝트 이름"
  default     = "terraform-example"
}
