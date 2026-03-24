# compute 모듈 입력 변수 정의

variable "environment" {
  type        = string
  description = "배포 환경 (dev, stg, prd)"
}

variable "vpc_id" {
  type        = string
  description = "EC2 인스턴스가 배포될 VPC ID"
}

variable "subnet_id" {
  type        = string
  description = "EC2 인스턴스가 배포될 서브넷 ID"
}

variable "ami_id" {
  type        = string
  description = "EC2 인스턴스에 사용할 AMI ID"
}

variable "instance_type" {
  type        = string
  description = "EC2 인스턴스 타입"
  default     = "t3.micro"
}

variable "project" {
  type        = string
  description = "프로젝트 이름"
  default     = "terraform-example"
}
