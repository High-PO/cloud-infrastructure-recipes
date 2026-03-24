# IAM 권한 리소스 정의
# 마이그레이션 후: IAM Role, Policy, Instance Profile을 별도 파일로 분리

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
