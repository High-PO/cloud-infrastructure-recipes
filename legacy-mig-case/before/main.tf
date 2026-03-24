# 레거시 메인 파일
# 모든 리소스를 하나의 파일에 정의 - 마이그레이션 전 상태

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

# 보안 그룹 - EC2 인스턴스 방화벽 규칙
resource "aws_security_group" "ec2" {
  name        = "${var.project}-${var.environment}-ec2-sg"
  description = "EC2 인스턴스용 보안 그룹"
  vpc_id      = aws_vpc.main.id

  # 인바운드 규칙 - SSH 접근 허용
  ingress {
    description = "SSH 접근"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 인바운드 규칙 - HTTP 접근 허용
  ingress {
    description = "HTTP 접근"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 규칙 - 모든 트래픽 허용
  egress {
    description = "모든 아웃바운드 트래픽 허용"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-ec2-sg"
      Environment = var.environment
    }
  )
}

# IAM 역할 - EC2 인스턴스가 AWS 서비스에 접근하기 위한 역할
resource "aws_iam_role" "ec2_role" {
  name = "${var.project}-${var.environment}-ec2-role"

  # 신뢰 정책 - EC2 서비스가 이 역할을 사용할 수 있도록 허용
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-ec2-role"
      Environment = var.environment
    }
  )
}

# IAM 정책 - S3 읽기 권한 정의
resource "aws_iam_policy" "s3_read_policy" {
  name        = "${var.project}-${var.environment}-s3-read-policy"
  description = "S3 버킷 읽기 권한 정책"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-s3-read-policy"
      Environment = var.environment
    }
  )
}

# IAM 정책 연결 - 역할에 정책 부여
resource "aws_iam_role_policy_attachment" "ec2_s3_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

# IAM 인스턴스 프로파일 - EC2에 IAM 역할 연결
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-ec2-profile"
      Environment = var.environment
    }
  )
}

# EC2 인스턴스 - 가상 서버 생성
resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # 루트 볼륨 설정
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-instance"
      Environment = var.environment
    }
  )
}

# S3 버킷 - 객체 스토리지
resource "aws_s3_bucket" "main" {
  bucket = "${var.bucket_name}-${var.environment}"

  tags = merge(
    var.tags,
    {
      Name        = "${var.bucket_name}-${var.environment}"
      Environment = var.environment
    }
  )
}

# S3 버킷 버저닝 설정 - 객체 버전 관리 활성화
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 버킷 암호화 설정 - 서버 측 암호화 활성화
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 버킷 퍼블릭 액세스 차단 - 보안 강화
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 버킷 정책 - IAM 역할의 접근 허용
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2RoleAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_role.arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
      }
    ]
  })
}
