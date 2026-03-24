# 루트 모듈 변수 정의
# 모듈 케이스: 루트 모듈에서 사용하는 모든 변수 정의

# 기본 환경 변수
variable "environment" {
  type        = string
  description = "배포 환경 (dev, stg, prd)"
}

variable "region" {
  type        = string
  description = "AWS 리전"
  default     = "ap-northeast-2"
}

variable "project" {
  type        = string
  description = "프로젝트 이름"
  default     = "terraform-example"
}

# 네트워킹 모듈 관련 변수
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR 블록"
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  type        = number
  description = "생성할 서브넷 개수"
  default     = 2
}

# 컴퓨트 모듈 관련 변수
variable "ami_id" {
  type        = string
  description = "EC2 인스턴스에 사용할 AMI ID"
}

variable "instance_type" {
  type        = string
  description = "EC2 인스턴스 타입"
  default     = "t3.micro"
}

# S3 버킷 관련 변수
variable "bucket_name" {
  type        = string
  description = "생성할 S3 버킷 이름"
}

variable "enable_versioning" {
  type        = bool
  description = "S3 버킷 버저닝 활성화 여부"
  default     = true
}

# 공통 태그
variable "common_tags" {
  type        = map(string)
  description = "모든 리소스에 적용할 공통 태그"
  default     = {}
}
