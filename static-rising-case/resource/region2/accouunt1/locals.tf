# 로컬 변수 정의 - 프리픽스 네이밍, 태그, 리소스 맵

locals {
  # 리전 약어 매핑
  region_short = {
    "ap-northeast-2" = "an2"
    "us-west-1"      = "uw1"
    "us-east-1"      = "ue1"
  }

  # 프리픽스 네이밍 규칙: ${environment}-${region_short}-${account}-${resource_type}
  prefix = "${var.environment}-${local.region_short[var.region]}-${var.account}"

  # 공통 태그 맵
  common_tags = {
    Environment = var.environment
    Region      = var.region
    Account     = var.account
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  # VPC 리소스 정의 맵 (for_each용)
  vpcs = {
    main = {
      cidr_block           = "10.0.0.0/16"
      enable_dns_hostnames = true
      enable_dns_support   = true
    }
    secondary = {
      cidr_block           = "10.1.0.0/16"
      enable_dns_hostnames = true
      enable_dns_support   = true
    }
  }

  # 서브넷 리소스 정의 맵 (for_each용)
  subnets = {
    public-a = {
      vpc_key             = "main"
      cidr_block          = "10.0.1.0/24"
      availability_zone   = "us-west-1a"
      map_public_ip       = true
    }
    public-c = {
      vpc_key             = "main"
      cidr_block          = "10.0.2.0/24"
      availability_zone   = "us-west-1c"
      map_public_ip       = true
    }
    private-a = {
      vpc_key             = "main"
      cidr_block          = "10.0.11.0/24"
      availability_zone   = "us-west-1a"
      map_public_ip       = false
    }
    private-c = {
      vpc_key             = "main"
      cidr_block          = "10.0.12.0/24"
      availability_zone   = "us-west-1c"
      map_public_ip       = false
    }
  }

  # Security Group 규칙 정의 (dynamic 블록용)
  security_group_rules = {
    ingress = [
      {
        description = "HTTP from anywhere"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "HTTPS from anywhere"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "SSH from VPC"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
      }
    ]
    egress = [
      {
        description = "All outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}
