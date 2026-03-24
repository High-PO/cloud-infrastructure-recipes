# 주의
해당 프로젝트는 Kiro IDE의 Agent 성능을 체크하기 위한 레포지토리 프로젝트 입니다.
지속적인 고도화 예정이며, 실제로 코드를 수정하기 보다 AI가 DevOps 철학을 이해하며 현실과 이상간 간극을 줄이는 작업을 잘 진행할 수 있는 프롬포트를 레포지토리에서 제공하는 방향으로 기록을 남길 예정입니다.

# Terraform 케이스별 예제 프로젝트

테라폼(Terraform) 인프라 코드를 케이스별로 정리한 예제 프로젝트입니다. 실무에서 자주 접하는 세 가지 테라폼 구성 패턴을 통해 코드 구조화, 모듈 활용, 고급 문법 활용 방법을 학습할 수 있습니다.

## 프로젝트 목적

- 레거시 테라폼 코드를 체계적으로 리팩토링하는 방법 제시
- 커스텀 모듈과 레지스트리 모듈을 활용한 재사용 가능한 인프라 코드 작성법 제공
- 테라폼 내장 문법(for_each, dynamic, locals, data sources)을 극대화한 코드 패턴 소개
- 실무에서 바로 적용 가능한 파일 구조 및 네이밍 규칙 예시 제공

## 케이스 소개

### 1. [Legacy Migration Case](./legacy-mig-case/)

단일 main.tf에 모든 리소스가 집중된 레거시 코드를 파일별/환경별로 분리하는 마이그레이션 과정을 보여줍니다.

**주요 내용:**
- Before: 모든 리소스가 하나의 main.tf에 집중된 레거시 구조
- After: 리소스 타입별 파일 분리 (vpc.tf, ec2.tf, s3.tf, iam.tf)
- 환경별 tfvars 파일을 통한 변수 관리 (dev/stg/prd)
- 버전 고정 및 출력 정의

**적합한 경우:**
- 기존 레거시 테라폼 코드를 리팩토링해야 할 때
- 파일 분리 및 구조화 방법을 학습하고 싶을 때

### 2. [Module Case](./module-case/)

커스텀 모듈과 레지스트리 모듈을 혼합 사용하여 재사용 가능한 인프라 코드를 작성하는 방법을 보여줍니다.

**주요 내용:**
- 커스텀 모듈 작성 (networking, compute)
- 레지스트리 모듈 활용 (terraform-aws-modules/s3-bucket/aws)
- 모듈 간 출력→입력 연결 패턴
- 버전 고정 전략

**적합한 경우:**
- 여러 프로젝트에서 재사용 가능한 모듈을 만들고 싶을 때
- 모듈 간 의존성 관리 방법을 학습하고 싶을 때

### 3. [Static Rising Case](./static-rising-case/)

모듈 없이 테라폼 내장 문법만으로 효율적인 코드를 작성하는 패턴을 보여줍니다.

**주요 내용:**
- for_each를 활용한 다중 리소스 생성
- dynamic 블록을 활용한 반복 가능한 중첩 블록 생성
- locals를 활용한 프리픽스 네이밍 규칙 적용
- data sources를 활용한 기존 리소스 참조
- 리전/계정별 디렉토리 구조 및 상태 파일 격리

**적합한 경우:**
- 모듈 없이 간결한 코드를 작성하고 싶을 때
- 테라폼 고급 문법을 학습하고 싶을 때
- 멀티 리전/멀티 계정 환경을 관리해야 할 때

## 공통 사항

### 백엔드 설정

모든 케이스는 동일한 백엔드 패턴을 사용합니다:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "<case>/<path>/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
```

- **S3**: 테라폼 상태 파일 저장
- **DynamoDB**: 동시 실행 방지를 위한 상태 잠금
- **Key 격리**: 케이스/경로별로 고유한 key를 사용하여 상태 파일 격리

### 프로바이더 설정

모든 케이스는 AWS 프로바이더를 사용하며, 리전은 변수로 관리합니다:

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}
```

### 사용 방법

각 케이스의 배포 가능한 디렉토리에서 다음 명령을 실행합니다:

```bash
# 초기화
terraform init

# 계획 확인 (환경별 tfvars 사용)
terraform plan -var-file=envs/dev.tfvars

# 적용 (실제 배포는 권장하지 않음 - 예제 목적)
terraform apply -var-file=envs/dev.tfvars
```

**주의:** 본 프로젝트는 학습 및 참고 목적의 예제 코드입니다. 실제 AWS 리소스 배포 시 비용이 발생할 수 있으므로 주의하시기 바랍니다.

## 프로젝트 구조

```
.
├── legacy-mig-case/          # 레거시 마이그레이션 케이스
│   ├── before/               # 마이그레이션 전 (레거시 구조)
│   ├── after/                # 마이그레이션 후 (개선된 구조)
│   └── README.md
├── module-case/              # 모듈 활용 케이스
│   ├── modules/              # 커스텀 모듈
│   │   ├── networking/
│   │   └── compute/
│   ├── root/                 # 루트 모듈
│   └── README.md
├── static-rising-case/       # 스태틱 라이징 케이스
│   ├── resource/
│   │   ├── region1/
│   │   │   ├── account1/
│   │   │   └── account2/
│   │   └── region2/
│   │       ├── account2/
│   │       └── accouunt1/    # 오타 유지 (예제 목적)
│   └── README.md
└── README.md                 # 본 문서
```

## 학습 순서 권장

1. **Legacy Migration Case**: 기본적인 파일 분리 및 구조화 방법 학습
2. **Module Case**: 모듈 작성 및 활용 방법 학습
3. **Static Rising Case**: 고급 테라폼 문법 및 멀티 환경 관리 학습

## 참고 자료

- [Terraform 공식 문서](https://www.terraform.io/docs)
- [Terraform AWS Provider 문서](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Registry](https://registry.terraform.io/)

## 라이선스

본 프로젝트는 학습 및 참고 목적으로 제공됩니다.
