# VPC 네트워크 리소스 정의
# 마이그레이션 후: VPC, Subnet, Internet Gateway, Route Table을 별도 파일로 분리

# VPC 리소스 - 가상 프라이빗 클라우드 생성
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-vpc"
      Environment = var.environment
    }
  )
}

# 퍼블릭 서브넷 - 인터넷 게이트웨이를 통해 외부 접근 가능
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-public-subnet"
      Environment = var.environment
      Type        = "Public"
    }
  )
}

# 프라이빗 서브넷 - 외부 접근 불가, 내부 통신용
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-private-subnet"
      Environment = var.environment
      Type        = "Private"
    }
  )
}

# 인터넷 게이트웨이 - VPC와 인터넷 간 통신 제공
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-igw"
      Environment = var.environment
    }
  )
}

# 라우트 테이블 - 퍼블릭 서브넷용 라우팅 규칙
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-public-rt"
      Environment = var.environment
    }
  )
}

# 라우트 테이블 연결 - 퍼블릭 서브넷에 라우트 테이블 적용
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
