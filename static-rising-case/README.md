# Static Rising Case - 테라폼 내장 문법 활용 패턴

## 개요

Static Rising Case는 모듈을 사용하지 않고 테라폼의 내장 문법(`for_each`, `dynamic`, `locals`, `data sources`)을 극대화하여 인프라 코드를 구성하는 패턴입니다. 리전과 계정별로 디렉토리를 분리하고, 일관된 프리픽스 네이밍 규칙을 적용하여 대규모 멀티 리전/멀티 계정 환경을 효율적으로 관리합니다.

## 디렉토리 구조

```
static-rising-case/
├── README.md
└── resource/
    ├── region1/
    │   ├── account1/
    │   │   ├── terraform.tf      # 테라폼/프로바이더 버전 및 백엔드 설정
    │   │   ├── locals.tf          # 프리픽스 네이밍, 태그, 리소스 정의 맵
    │   │   ├── variables.tf       # 리전/계정별 변수
    │   │   ├── data.tf            # 데이터 소스 (AMI, 가용영역 등)
    │   │   ├── main.tf            # 리소스 정의 (for_each, dynamic 활용)
    │   │   └── outputs.tf         # 출력 정의
    │   └── account2/
    │       └── (동일 구조)
    └── region2/
        ├── account2/
        │   └── (동일 구조)
        └── accouunt1/
            └── (동일 구조)
```

### 디렉토리 구조 설명

- **resource/**: 모든 리소스 정의의 루트 디렉토리
- **region1/, region2/**: 리전별 분리 (예: ap-northeast-2, us-west-1)
- **account1/, account2/**: 계정별 분리 (각 리전-계정 조합마다 독립적인 상태 파일 관리)
- 각 리전-계정 디렉토리는 독립적으로 배포 가능한 완전한 테라폼 구성을 포함

## 프리픽스 네이밍 규칙

### 네이밍 형식

```
${environment}-${region_short}-${account}-${resource_type}
```

### 구성 요소

- **environment**: 배포 환경 (dev, stg, prd)
- **region_short**: 리전 약어 (an2=ap-northeast-2, uw1=us-west-1, ue1=us-east-1)
- **account**: 계정 식별자 (account1, account2)
- **resource_type**: 리소스 유형 (vpc, subnet, sg, ec2 등)

### 네이밍 예시

```
prd-an2-account1-vpc-main
dev-uw1-account2-subnet-public-a
stg-an2-account1-sg-web
```

### locals.tf에서의 구현

```hcl
locals {
  # 리전 약어 매핑
  region_short = {
    "ap-northeast-2" = "an2"
    "us-west-1"      = "uw1"
    "us-east-1"      = "ue1"
  }

  # 프리픽스 생성
  prefix = "${var.environment}-${local.region_short[var.region]}-${var.account}"

  # 리소스 이름 적용 예시
  # Name = "${local.prefix}-vpc-${each.key}"
  # 결과: prd-an2-account1-vpc-main
}
```

## 테라폼 문법 패턴

### 1. for_each - 반복 리소스 생성

`for_each`를 사용하여 맵 또는 셋에서 여러 유사한 리소스를 생성합니다.

#### locals.tf에서 리소스 맵 정의

```hcl
locals {
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

  subnets = {
    public-a = {
      vpc_key             = "main"
      cidr_block          = "10.0.1.0/24"
      availability_zone   = "ap-northeast-2a"
      map_public_ip       = true
    }
    public-c = {
      vpc_key             = "main"
      cidr_block          = "10.0.2.0/24"
      availability_zone   = "ap-northeast-2c"
      map_public_ip       = true
    }
  }
}
```

#### main.tf에서 for_each 활용

```hcl
# VPC 리소스 생성
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

# 서브넷 리소스 생성
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
    }
  )
}
```

**장점:**
- 리소스 정의를 데이터와 분리하여 관리 용이
- 새로운 리소스 추가 시 맵에만 항목 추가
- 리소스 간 참조가 명확 (예: `aws_vpc.this[each.value.vpc_key].id`)

### 2. dynamic - 중첩 블록 동적 생성

`dynamic` 블록을 사용하여 리소스 내부의 반복되는 중첩 블록을 동적으로 생성합니다.

#### locals.tf에서 규칙 정의

```hcl
locals {
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
```

#### main.tf에서 dynamic 블록 활용

```hcl
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
```

**장점:**
- 반복되는 중첩 블록을 간결하게 표현
- 규칙 추가/삭제가 리스트 수정만으로 가능
- 코드 중복 제거

### 3. locals - 계산된 값 및 공통 설정

`locals` 블록을 사용하여 반복 사용되는 값, 계산된 값, 공통 설정을 정의합니다.

```hcl
locals {
  # 리전 약어 매핑
  region_short = {
    "ap-northeast-2" = "an2"
    "us-west-1"      = "uw1"
  }

  # 프리픽스 네이밍
  prefix = "${var.environment}-${local.region_short[var.region]}-${var.account}"

  # 공통 태그
  common_tags = {
    Environment = var.environment
    Region      = var.region
    Account     = var.account
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  # 리소스 정의 맵
  vpcs = { ... }
  subnets = { ... }
  security_group_rules = { ... }
}
```

**활용 사례:**
- **프리픽스 네이밍**: 모든 리소스 이름에 일관된 접두사 적용
- **공통 태그**: 모든 리소스에 동일한 태그 세트 적용
- **리소스 맵**: for_each에서 사용할 데이터 구조 정의
- **계산된 값**: 변수를 조합하여 새로운 값 생성

### 4. data sources - 기존 리소스 참조

`data` 소스를 사용하여 기존 AWS 리소스나 정보를 조회합니다.

#### data.tf 예시

```hcl
# 최신 Amazon Linux 2 AMI 조회
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 사용 가능한 가용 영역 조회
data "aws_availability_zones" "available" {
  state = "available"
}

# 현재 AWS 계정 정보 조회
data "aws_caller_identity" "current" {}

# 현재 AWS 리전 정보 조회
data "aws_region" "current" {}
```

**활용 예시:**

```hcl
# EC2 인스턴스에서 AMI 참조
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  # ...
}

# 출력에서 계정 정보 사용
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
```

**장점:**
- 하드코딩 없이 동적으로 값 조회
- 최신 AMI 자동 선택
- 환경별로 다른 값을 자동으로 가져옴

## 상태 파일 관리

### 리전-계정별 상태 파일 격리

각 리전-계정 조합마다 독립적인 상태 파일을 유지합니다.

```hcl
# resource/region1/account1/terraform.tf
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "static-rising/region1/account1/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

# resource/region2/account2/terraform.tf
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "static-rising/region2/account2/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
```

**장점:**
- 리전-계정별 독립적인 배포 가능
- 상태 파일 충돌 방지
- 장애 격리 (한 리전의 문제가 다른 리전에 영향 없음)

## 사용법

### 1. 초기화

특정 리전-계정 디렉토리로 이동하여 초기화합니다.

```bash
cd resource/region1/account1
terraform init
```

### 2. 변수 설정

환경별 변수를 설정합니다. 변수는 다음 방법으로 제공할 수 있습니다:

**방법 1: 환경 변수**
```bash
export TF_VAR_environment="dev"
export TF_VAR_project="my-project"
```

**방법 2: tfvars 파일 생성**
```bash
# dev.tfvars 파일 생성
cat > dev.tfvars <<EOF
environment = "dev"
project     = "my-project"
region      = "ap-northeast-2"
account     = "account1"
EOF
```

### 3. 계획 확인

```bash
# 환경 변수 사용 시
terraform plan

# tfvars 파일 사용 시
terraform plan -var-file=dev.tfvars
```

### 4. 적용

```bash
# 환경 변수 사용 시
terraform apply

# tfvars 파일 사용 시
terraform apply -var-file=dev.tfvars
```

### 5. 다른 리전-계정 배포

```bash
# 다른 리전-계정으로 이동
cd ../../../region2/account2

# 동일한 절차 반복
terraform init
terraform plan -var-file=prd.tfvars
terraform apply -var-file=prd.tfvars
```

## 주요 개념

### 모듈 없이 코드 재사용

Static Rising 패턴은 모듈을 사용하지 않고도 다음 방법으로 코드 재사용을 달성합니다:

1. **for_each**: 동일한 리소스 블록으로 여러 인스턴스 생성
2. **locals**: 공통 설정과 데이터 구조를 중앙 집중식으로 관리
3. **디렉토리 복제**: 리전-계정별로 동일한 파일 구조 복제 (설정 값만 변경)

### 언제 이 패턴을 사용하는가?

**적합한 경우:**
- 리전-계정별로 유사하지만 독립적인 인프라 구성
- 모듈 오버헤드 없이 간단한 구조 유지
- 각 환경의 완전한 가시성 필요
- 테라폼 내장 기능 학습 및 활용

**부적합한 경우:**
- 여러 프로젝트에서 재사용할 공통 컴포넌트
- 복잡한 추상화가 필요한 경우
- 버전 관리가 필요한 공유 컴포넌트

### 모듈 케이스와의 비교

| 특성 | Static Rising | Module Case |
|------|---------------|-------------|
| 재사용 방식 | for_each + 디렉토리 복제 | 모듈 호출 |
| 추상화 수준 | 낮음 (명시적) | 높음 (캡슐화) |
| 학습 곡선 | 낮음 | 중간 |
| 유지보수 | 각 디렉토리 개별 수정 | 모듈 버전 관리 |
| 가시성 | 높음 (모든 코드 직접 확인) | 중간 (모듈 내부 확인 필요) |
| 적용 범위 | 단일 프로젝트 | 다중 프로젝트 |

## 참고 사항

- 본 예제는 학습 및 참고 목적으로 작성되었으며, 실제 AWS 리소스를 생성하지 않습니다
- 실제 배포 시에는 백엔드 설정(S3 버킷, DynamoDB 테이블)을 먼저 생성해야 합니다
- 각 리전-계정 디렉토리는 독립적으로 관리되므로, 변경 사항을 모든 디렉토리에 동기화해야 할 수 있습니다
- 프리픽스 네이밍 규칙은 조직의 표준에 맞게 조정할 수 있습니다
