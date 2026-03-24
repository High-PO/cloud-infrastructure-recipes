# 메인 리소스 정의 - for_each 및 dynamic 블록 활용

# VPC 리소스 생성 (for_each 사용)
resource "aws_vpc" "this" {
  for_each = local.vpcs

  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = each.value.enable_dns_hostnames
  enable_dns_support   = each.value.enable_dns_support

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-vpc-${each.key}"
    }
  )
}

# 서브넷 리소스 생성 (for_each 사용)
resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.this[each.value.vpc_key].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-subnet-${each.key}"
      Type = each.value.map_public_ip ? "public" : "private"
    }
  )
}

# Internet Gateway 생성
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.this["main"].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-igw"
    }
  )
}

# 라우트 테이블 생성
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this["main"].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-rt-public"
    }
  )
}

# Security Group 생성 (dynamic 블록 사용)
resource "aws_security_group" "web" {
  name        = "${local.prefix}-sg-web"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.this["main"].id

  # Ingress 규칙 동적 생성
  dynamic "ingress" {
    for_each = local.security_group_rules.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Egress 규칙 동적 생성
  dynamic "egress" {
    for_each = local.security_group_rules.egress
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-sg-web"
    }
  )
}
