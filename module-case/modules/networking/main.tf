# VPC 리소스 생성
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-${var.project}-vpc"
    Environment = var.environment
    Project     = var.project
  }
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-${var.project}-igw"
    Environment = var.environment
    Project     = var.project
  }
}

# 가용 영역 데이터 소스
data "aws_availability_zones" "available" {
  state = "available"
}

# 퍼블릭 서브넷 생성
resource "aws_subnet" "public" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${var.project}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project
    Type        = "public"
  }
}

# 퍼블릭 라우트 테이블 생성
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-${var.project}-public-rt"
    Environment = var.environment
    Project     = var.project
  }
}

# 인터넷 게이트웨이로 향하는 라우트 추가
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# 퍼블릭 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "public" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
