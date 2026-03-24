# 레거시 마이그레이션 케이스

## 개요

이 케이스는 단일 `main.tf` 파일에 모든 리소스가 집중된 레거시 테라폼 코드를 파일별/환경별로 분리하는 마이그레이션 과정을 보여줍니다. 실제 레거시 코드 리팩토링 시 단계별 가이드로 활용할 수 있습니다.

## 디렉토리 구조

### Before (마이그레이션 전)

```
before/
├── provider.tf      # 프로바이더 및 백엔드 설정
├── variables.tf     # 모든 변수를 환경 구분 없이 정의
└── main.tf          # 모든 리소스(VPC, Subnet, SG, EC2, S3, IAM)가 하나의 파일에 집중
```

**문제점:**
- 모든 리소스가 하나의 파일에 있어 가독성이 떨어짐
- 환경별 설정이 분리되지 않아 관리가 어려움
- 리소스 타입별 구분이 없어 유지보수가 어려움

### After (마이그레이션 후)

```
after/
├── versions.tf      # 테라폼 및 프로바이더 버전 고정
├── provider.tf      # 프로바이더 및 백엔드 설정
├── variables.tf     # 공통 변수 정의
├── vpc.tf           # VPC, Subnet, Internet Gateway, Route Table
├── ec2.tf           # EC2 Instance, Security Group
├── s3.tf            # S3 Bucket, Bucket Policy
├── iam.tf           # IAM Role, Policy, Instance Profile
├── outputs.tf       # 주요 리소스 속성 출력
└── envs/
    ├── dev.tfvars   # 개발 환경 변수 값
    ├── stg.tfvars   # 스테이징 환경 변수 값
    └── prd.tfvars   # 프로덕션 환경 변수 값
```

**개선점:**
- 리소스 타입별로 파일이 분리되어 가독성 향상
- 환경별 변수가 tfvars 파일로 분리되어 관리 용이
- 버전 고정으로 안정성 확보
- 출력 값이 명확히 정의되어 다른 모듈과의 연동 용이

## 마이그레이션 단계 가이드

### 1단계: 버전 고정 파일 생성

먼저 테라폼 및 프로바이더 버전을 고정하는 `versions.tf` 파일을 생성합니다.

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
```

### 2단계: 리소스 타입별 파일 분리

`main.tf`에서 리소스를 타입별로 추출하여 별도 파일로 분리합니다.

- **네트워크 리소스** → `vpc.tf`
  - aws_vpc
  - aws_subnet
  - aws_internet_gateway
  - aws_route_table
  - aws_route_table_association

- **컴퓨팅 리소스** → `ec2.tf`
  - aws_instance
  - aws_security_group

- **스토리지 리소스** → `s3.tf`
  - aws_s3_bucket
  - aws_s3_bucket_*

- **IAM 리소스** → `iam.tf`
  - aws_iam_role
  - aws_iam_policy
  - aws_iam_role_policy_attachment
  - aws_iam_instance_profile

### 3단계: 환경별 변수 분리

`variables.tf`에는 변수 정의만 남기고, 실제 값은 환경별 tfvars 파일로 분리합니다.

```hcl
# variables.tf - 변수 정의만
variable "environment" {
  type        = string
  description = "배포 환경 (dev, stg, prd)"
}

variable "instance_type" {
  type        = string
  description = "EC2 인스턴스 타입"
}
```

```hcl
# envs/dev.tfvars - 개발 환경 값
environment   = "dev"
instance_type = "t3.micro"
```

```hcl
# envs/prd.tfvars - 프로덕션 환경 값
environment   = "prd"
instance_type = "t3.large"
```

### 4단계: 출력 값 정의

주요 리소스의 속성을 `outputs.tf`에 정의하여 다른 모듈이나 스택에서 참조할 수 있도록 합니다.

```hcl
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "instance_id" {
  description = "EC2 인스턴스 ID"
  value       = aws_instance.main.id
}
```

## 사용법

### 초기화

테라폼을 초기화하여 프로바이더를 다운로드하고 백엔드를 설정합니다.

```bash
# Before 디렉토리
cd before
terraform init

# After 디렉토리
cd after
terraform init
```

### 환경별 배포 (After 디렉토리)

환경별 tfvars 파일을 사용하여 배포합니다.

```bash
# 개발 환경 배포
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars

# 스테이징 환경 배포
terraform plan -var-file=envs/stg.tfvars
terraform apply -var-file=envs/stg.tfvars

# 프로덕션 환경 배포
terraform plan -var-file=envs/prd.tfvars
terraform apply -var-file=envs/prd.tfvars
```

### Workspace를 사용한 환경 분리 (선택사항)

Workspace를 사용하면 동일한 코드로 여러 환경을 관리할 수 있습니다.

```bash
# Workspace 생성
terraform workspace new dev
terraform workspace new stg
terraform workspace new prd

# Workspace 전환 및 배포
terraform workspace select dev
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars

# 현재 Workspace 확인
terraform workspace show

# Workspace 목록 확인
terraform workspace list
```

### 리소스 확인

배포된 리소스를 확인합니다.

```bash
# 상태 파일 확인
terraform state list

# 특정 리소스 상세 정보
terraform state show aws_vpc.main

# 출력 값 확인
terraform output
```

### 리소스 삭제

```bash
# 개발 환경 리소스 삭제
terraform destroy -var-file=envs/dev.tfvars
```

## 주요 개념

### 파일 분리의 이점

1. **가독성 향상**: 리소스 타입별로 파일이 분리되어 코드를 쉽게 찾고 이해할 수 있습니다.
2. **유지보수 용이**: 특정 리소스를 수정할 때 해당 파일만 열면 됩니다.
3. **협업 효율**: 팀원들이 서로 다른 파일을 동시에 작업할 수 있습니다.
4. **코드 리뷰 간소화**: 변경 사항이 명확히 구분되어 리뷰가 쉬워집니다.

### 환경별 변수 분리의 이점

1. **환경별 설정 관리**: 개발/스테이징/프로덕션 환경의 설정을 명확히 구분할 수 있습니다.
2. **실수 방지**: 환경별로 다른 값을 사용하여 프로덕션에 개발 설정이 적용되는 실수를 방지합니다.
3. **확장성**: 새로운 환경을 추가할 때 tfvars 파일만 추가하면 됩니다.

### 버전 고정의 중요성

1. **재현 가능성**: 동일한 버전으로 언제든지 동일한 결과를 얻을 수 있습니다.
2. **안정성**: 예기치 않은 프로바이더 업데이트로 인한 문제를 방지합니다.
3. **팀 협업**: 모든 팀원이 동일한 버전을 사용하여 일관성을 유지합니다.

## 마이그레이션 체크리스트

- [ ] `versions.tf` 파일 생성 및 버전 고정
- [ ] 리소스를 타입별로 파일 분리 (vpc.tf, ec2.tf, s3.tf, iam.tf)
- [ ] 환경별 tfvars 파일 생성 (dev, stg, prd)
- [ ] `outputs.tf` 파일 생성 및 주요 출력 값 정의
- [ ] 각 환경에서 `terraform plan` 실행하여 변경 사항 확인
- [ ] 테스트 환경에서 먼저 적용 후 프로덕션 적용
- [ ] 기존 상태 파일 백업 및 마이그레이션 검증

## 참고 사항

- 이 예제는 학습 목적으로 작성되었으며, 실제 AWS 리소스를 생성하지 않습니다.
- 실제 배포 시에는 백엔드 설정(S3 버킷, DynamoDB 테이블)을 먼저 생성해야 합니다.
- AMI ID는 리전별로 다르므로, 사용하는 리전에 맞는 AMI ID로 변경해야 합니다.
- 프로덕션 환경에서는 보안 그룹 규칙을 더 엄격하게 설정해야 합니다.
