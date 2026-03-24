# 변수 정의 파일
# 마이그레이션 후: 공통 변수를 정의하고, 환경별 값은 tfvars 파일로 분리

# 기본 설정 변수
variable "region" {
  type        = string
  description = "AWS 리전"
  default     = "ap-northeast-2"
}

variable "environment" {
  type        = string
  description = "배포 환경 (dev, stg, prd)"
}

variable "project" {
  type        = string
  description = "프로젝트 이름"
}

# 네트워크 설정 변수
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR 블록"
}

variable "public_subnet_cidr" {
  type        = string
  description = "퍼블릭 서브넷 CIDR 블록"
}

variable "private_subnet_cidr" {
  type        = string
  description = "프라이빗 서브넷 CIDR 블록"
}

variable "availability_zone" {
  type        = string
  description = "가용 영역"
}

# EC2 설정 변수
variable "instance_type" {
  type        = string
  description = "EC2 인스턴스 타입"
}

variable "ami_id" {
  type        = string
  description = "EC2 AMI ID"
}

# S3 설정 변수
variable "bucket_name" {
  type        = string
  description = "S3 버킷 이름"
}

# 태그 설정 변수
variable "tags" {
  type        = map(string)
  description = "리소스에 적용할 공통 태그"
  default     = {}
}
