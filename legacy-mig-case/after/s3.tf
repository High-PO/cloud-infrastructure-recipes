# S3 스토리지 리소스 정의
# 마이그레이션 후: S3 Bucket, Bucket Policy를 별도 파일로 분리

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
