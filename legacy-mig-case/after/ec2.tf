# EC2 컴퓨팅 리소스 정의
# 마이그레이션 후: EC2 Instance, Security Group을 별도 파일로 분리

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
