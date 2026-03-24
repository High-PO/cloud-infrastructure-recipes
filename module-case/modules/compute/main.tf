# Security Group 생성
resource "aws_security_group" "instance" {
  name        = "${var.environment}-${var.project}-instance-sg"
  description = "EC2 인스턴스용 보안 그룹"
  vpc_id      = var.vpc_id

  # SSH 접근 허용
  ingress {
    description = "SSH 접근"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP 접근 허용
  ingress {
    description = "HTTP 접근"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS 접근 허용
  ingress {
    description = "HTTPS 접근"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    description = "모든 아웃바운드 트래픽"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.project}-instance-sg"
    Environment = var.environment
    Project     = var.project
  }
}

# EC2 인스턴스 생성
resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Name        = "${var.environment}-${var.project}-instance"
    Environment = var.environment
    Project     = var.project
  }
}
