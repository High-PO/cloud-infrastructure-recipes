# 변수 정의 파일
# 레거시 상태: 모든 변수를 환경 구분 없이 단일 파일에 정의

# 기본 설정 변수
variable "region" {
  type        = string
  description = "AWS 리전"
  default     = "ap-northeast-2"
}

variable "environment" {
  type        = string
  description = "배포 환경 (dev, stg, prd)"
  default     = "dev"
}

variable "project" {
  type        = string
  description = "프로젝트 이름"
  default     = "terraform-example"
}

# 네트워크 설정 변수
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR 블록"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "퍼블릭 서브넷 CIDR 블록"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "프라이빗 서브넷 CIDR 블록"
  default     = "10.0.11.0/24"
}

variable "availability_zone" {
  type        = string
  description = "가용 영역"
  default     = "ap-northeast-2a"
}

# EC2 설정 변수
variable "instance_type" {
  type        = string
  description = "EC2 인스턴스 타입"
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "EC2 AMI ID"
  default     = "ami-0c9c942bd7bf113a2"
}

# S3 설정 변수
variable "bucket_name" {
  type        = string
  description = "S3 버킷 이름"
  default     = "example-bucket"
}

# 태그 설정 변수
variable "tags" {
  type        = map(string)
  description = "리소스에 적용할 공통 태그"
  default = {
    ManagedBy = "Terraform"
    Project   = "terraform-example"
  }
}
