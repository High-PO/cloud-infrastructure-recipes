# Module Case - 모듈 활용 케이스

## 개요

이 케이스는 테라폼 모듈을 활용하여 재사용 가능하고 유지보수가 용이한 인프라 코드를 작성하는 방법을 보여줍니다. 커스텀 모듈과 레지스트리 모듈을 혼합 사용하며, 모듈 간 출력-입력 연결 패턴과 버전 고정 전략을 시연합니다.

## 디렉토리 구조

```
module-case/
├── modules/                    # 커스텀 모듈 디렉토리
│   ├── networking/            # 네트워킹 모듈 (VPC, Subnet, IGW)
│   │   ├── main.tf           # 네트워킹 리소스 정의
│   │   ├── variables.tf      # 모듈 입력 변수
│   │   └── outputs.tf        # 모듈 출력 값
│   └── compute/              # 컴퓨트 모듈 (EC2, Security Group)
│       ├── main.tf           # 컴퓨트 리소스 정의
│       ├── variables.tf      # 모듈 입력 변수
│       └── outputs.tf        # 모듈 출력 값
└── root/                      # 루트 모듈 (모듈 오케스트레이션)
    ├── main.tf               # 모듈 호출 및 조합
    ├── variables.tf          # 루트 변수 정의
    ├── outputs.tf            # 최종 출력 정의
    ├── provider.tf           # 프로바이더 및 백엔드 설정
    ├── versions.tf           # 버전 제약 정의
    └── envs/                 # 환경별 변수 파일
        ├── dev.tfvars        # 개발 환경 변수
        ├── stg.tfvars        # 스테이징 환경 변수
        └── prd.tfvars        # 프로덕션 환경 변수
```

## 모듈 구조 설명

### 커스텀 모듈 vs 레지스트리 모듈

#### 커스텀 모듈 (Custom Module)
- **위치**: `modules/` 디렉토리 내에 로컬로 관리
- **용도**: 프로젝트 특화 로직, 조직 표준 패턴 구현
- **장점**: 완전한 제어, 빠른 수정, 조직 요구사항 반영
- **예시**: `modules/networking`, `modules/compute`

#### 레지스트리 모듈 (Registry Module)
- **위치**: Terraform Registry에서 원격으로 참조
- **용도**: 검증된 커뮤니티/공식 모듈 활용
- **장점**: 검증된 코드, 유지보수 부담 감소, 모범 사례 적용
- **예시**: `terraform-aws-modules/s3-bucket/aws`

### 모듈 간 데이터 흐름

```
┌─────────────────┐
│   networking    │
│   module        │
│                 │
│  outputs:       │
│  - vpc_id       │───┐
│  - subnet_ids   │   │
└─────────────────┘   │
                      │ 모듈 간 출력→입력 연결
                      │
                      ▼
┌─────────────────┐
│   compute       │
│   module        │
│                 │
│  inputs:        │
│  - vpc_id       │
│  - subnet_id    │
└─────────────────┘
```

networking 모듈의 출력 값(`vpc_id`, `subnet_ids`)을 compute 모듈의 입력으로 전달하여 모듈 간 의존성을 명시적으로 관리합니다.

## 버전 고정 전략

### 1. 테라폼 및 프로바이더 버전 고정

`versions.tf` 파일에서 테라폼 코어 버전과 프로바이더 버전을 명시적으로 고정합니다:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

- `required_version`: 테라폼 코어 최소 버전 지정
- `required_providers`: 프로바이더 소스 및 버전 제약 명시

### 2. 레지스트리 모듈 버전 고정

레지스트리 모듈 호출 시 `version` 인자로 특정 버전을 고정합니다:

```hcl
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.2"  # 특정 버전 고정 (범위 연산자 사용 안 함)
  
  # ...
}
```

**권장 사항**:
- ✅ **권장**: `version = "4.2.2"` (특정 버전 고정)
- ❌ **비권장**: `version = "~> 4.2"` (범위 연산자 사용)
- ❌ **비권장**: `version = ">= 4.0"` (최소 버전만 지정)

특정 버전을 고정하면 예기치 않은 변경으로 인한 문제를 방지하고, 재현 가능한 인프라 배포를 보장합니다.

### 3. 커스텀 모듈 버전 관리

커스텀 모듈은 로컬 경로로 참조하므로 별도의 버전 인자가 없습니다:

```hcl
module "networking" {
  source = "../modules/networking"  # 상대 경로 참조
  
  # ...
}
```

프로덕션 환경에서는 Git 태그를 활용한 버전 관리를 고려할 수 있습니다:

```hcl
module "networking" {
  source = "git::https://github.com/org/repo.git//modules/networking?ref=v1.2.3"
}
```

## 사용법

### 1. 초기화

```bash
cd module-case/root
terraform init
```

### 2. 환경별 배포

#### 개발 환경 배포

```bash
terraform plan -var-file="envs/dev.tfvars"
terraform apply -var-file="envs/dev.tfvars"
```

#### 스테이징 환경 배포

```bash
terraform plan -var-file="envs/stg.tfvars"
terraform apply -var-file="envs/stg.tfvars"
```

#### 프로덕션 환경 배포

```bash
terraform plan -var-file="envs/prd.tfvars"
terraform apply -var-file="envs/prd.tfvars"
```

### 3. 출력 확인

```bash
terraform output
```

주요 출력 값:
- `vpc_id`: 생성된 VPC ID
- `subnet_ids`: 서브넷 ID 목록
- `instance_id`: EC2 인스턴스 ID
- `instance_public_ip`: EC2 퍼블릭 IP
- `s3_bucket_id`: S3 버킷 ID
- `s3_bucket_arn`: S3 버킷 ARN

### 4. 리소스 정리

```bash
terraform destroy -var-file="envs/dev.tfvars"
```

## 주요 개념 및 패턴

### 1. 모듈 표준 구조

모든 커스텀 모듈은 다음 세 가지 파일을 포함합니다:

- **main.tf**: 리소스 정의
- **variables.tf**: 입력 변수 정의 (type, description 필수)
- **outputs.tf**: 출력 값 정의 (description 필수)

### 2. 모듈 간 의존성 관리

모듈 출력을 다른 모듈의 입력으로 전달하여 명시적인 의존성을 생성합니다:

```hcl
module "compute" {
  source    = "../modules/compute"
  vpc_id    = module.networking.vpc_id        # 의존성 명시
  subnet_id = module.networking.subnet_ids[0]
}
```

테라폼은 이 의존성을 자동으로 감지하여 올바른 순서로 리소스를 생성합니다.

### 3. 환경별 변수 분리

환경별 차이점을 tfvars 파일로 분리하여 관리합니다:

- **dev.tfvars**: 작은 인스턴스 타입, 최소 리소스
- **stg.tfvars**: 중간 인스턴스 타입, 프로덕션 유사 구성
- **prd.tfvars**: 큰 인스턴스 타입, 고가용성 구성

### 4. 태그 전략

공통 태그를 변수로 정의하고 `merge()` 함수로 리소스별 태그와 결합합니다:

```hcl
tags = merge(
  var.common_tags,
  {
    Name        = "${var.environment}-${var.project}-resource"
    Environment = var.environment
  }
)
```

## 모범 사례

1. **모듈 재사용성**: 환경별 하드코딩 값을 피하고 변수로 추상화
2. **명확한 인터페이스**: 모든 변수와 출력에 type과 description 명시
3. **버전 고정**: 레지스트리 모듈은 특정 버전으로 고정
4. **문서화**: 각 모듈에 README.md 추가 (실제 프로젝트에서 권장)
5. **검증**: 모듈 변경 시 모든 환경에서 plan 실행하여 영향 확인

## 참고 사항

- 이 예제는 학습 목적으로 작성되었으며, 실제 AWS 리소스를 생성하지 않습니다
- 실제 배포 시 백엔드 설정(S3 버킷, DynamoDB 테이블)을 먼저 생성해야 합니다
- AMI ID는 리전별로 다르므로 배포 리전에 맞게 수정이 필요합니다
- S3 버킷 이름은 전역적으로 고유해야 하므로 실제 배포 시 변경이 필요합니다
