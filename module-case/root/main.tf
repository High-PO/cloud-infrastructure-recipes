# 루트 모듈 메인 파일
# 커스텀 모듈(networking, compute)과 레지스트리 모듈(S3)을 조합하여 인프라 구성

# 네트워킹 모듈 호출 - VPC, 서브넷, 인터넷 게이트웨이 생성
module "networking" {
  source = "../modules/networking"

  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  subnet_count = var.subnet_count
  region       = var.region
  project      = var.project
}

# 컴퓨트 모듈 호출 - EC2 인스턴스 및 보안 그룹 생성
# networking 모듈의 출력(vpc_id, subnet_id)을 입력으로 전달
module "compute" {
  source = "../modules/compute"

  environment   = var.environment
  vpc_id        = module.networking.vpc_id              # 모듈 간 출력→입력 연결
  subnet_id     = module.networking.subnet_ids[0]       # 첫 번째 서브넷 사용
  ami_id        = var.ami_id
  instance_type = var.instance_type
  project       = var.project
}

# 레지스트리 모듈 호출 - terraform-aws-modules/s3-bucket/aws
# 특정 버전(4.2.2)으로 고정하여 안정성 확보
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.2"

  bucket = var.bucket_name

  # 버킷 버저닝 설정
  versioning = {
    enabled = var.enable_versioning
  }

  # 서버 측 암호화 활성화
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # 퍼블릭 액세스 차단 설정
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # 태그 설정
  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.project}-bucket"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
