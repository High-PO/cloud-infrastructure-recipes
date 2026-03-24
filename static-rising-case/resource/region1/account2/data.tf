# 데이터 소스 정의 - 기존 AWS 리소스 참조

# 최신 Amazon Linux 2 AMI 조회
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 사용 가능한 가용 영역 조회
data "aws_availability_zones" "available" {
  state = "available"
}

# 현재 AWS 계정 정보 조회
data "aws_caller_identity" "current" {}

# 현재 AWS 리전 정보 조회
data "aws_region" "current" {}
