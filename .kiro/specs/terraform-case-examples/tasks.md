# 구현 계획: 테라폼 케이스별 예제

## 개요

세 가지 테라폼 케이스(레거시 마이그레이션, 모듈, 스태틱 라이징)를 순차적으로 구현합니다. 각 케이스는 독립적이며, 공통 백엔드/프로바이더 패턴을 공유합니다.

## Tasks

- [ ] 1. Legacy Migration Case - Before (레거시 상태)
  - [x] 1.1 before/provider.tf 생성: S3 백엔드 + DynamoDB 잠금 설정, AWS 프로바이더 설정
    - terraform 블록에 required_version, required_providers(aws 버전 고정) 포함
    - backend "s3" 블록에 bucket, key, region, dynamodb_table, encrypt 설정
    - provider "aws" 블록에 var.region 참조
    - _Requirements: 1.1, 1.2, 1.4_
  - [x] 1.2 before/variables.tf 생성: 모든 변수를 환경 구분 없이 단일 파일에 정의
    - region, environment, project, vpc_cidr, instance_type, ami_id 등 모든 변수 포함
    - _Requirements: 2.2_
  - [x] 1.3 before/main.tf 생성: VPC, Subnet, Security Group, EC2, S3, IAM 리소스를 모두 하나의 파일에 작성
    - aws_vpc, aws_subnet, aws_security_group, aws_instance, aws_s3_bucket, aws_iam_role, aws_iam_policy 등 포함
    - 한국어 주석으로 각 리소스 설명
    - _Requirements: 2.1, 6.5_

- [ ] 2. Legacy Migration Case - After (마이그레이션 후)
  - [x] 2.1 after/versions.tf 생성: 테라폼 및 프로바이더 버전 고정
    - required_version과 required_providers 명시
    - _Requirements: 2.6, 5.5_
  - [x] 2.2 after/provider.tf 생성: 프로바이더 및 백엔드 설정
    - S3 백엔드 + DynamoDB 잠금
    - provider "aws"에 var.region 참조
    - _Requirements: 1.1, 1.2, 1.4, 5.1_
  - [x] 2.3 after/variables.tf 생성: 공통 변수 정의
    - 모든 변수에 type, description 명시
    - _Requirements: 5.2_
  - [x] 2.4 after/vpc.tf 생성: VPC, Subnet, Internet Gateway, Route Table 리소스
    - 한국어 주석 포함
    - _Requirements: 2.3, 5.4, 6.5_
  - [x] 2.5 after/ec2.tf 생성: EC2 Instance, Security Group 리소스
    - 한국어 주석 포함
    - _Requirements: 2.3, 5.4, 6.5_
  - [x] 2.6 after/s3.tf 생성: S3 Bucket, Bucket Policy 리소스
    - 한국어 주석 포함
    - _Requirements: 2.3, 5.4, 6.5_
  - [x] 2.7 after/iam.tf 생성: IAM Role, Policy, Instance Profile 리소스
    - 한국어 주석 포함
    - _Requirements: 2.3, 5.4, 6.5_
  - [x] 2.8 after/outputs.tf 생성: 주요 리소스 속성 출력
    - VPC ID, Subnet IDs, Instance ID, S3 Bucket ARN 등
    - _Requirements: 2.5, 5.3_
  - [x] 2.9 after/envs/ 디렉토리에 dev.tfvars, stg.tfvars, prd.tfvars 생성
    - 각 환경별 변수 값 차별화 (instance_type, vpc_cidr 등)
    - _Requirements: 2.4, 1.5_

- [ ] 3. Legacy Migration Case - README 및 체크포인트
  - [x] 3.1 legacy-mig-case/README.md 생성: before/after 구조 설명, 마이그레이션 단계 가이드
    - 디렉토리 구조 다이어그램 포함
    - 사용법 (terraform init, workspace, plan, apply) 설명
    - _Requirements: 2.7, 6.2, 6.3, 6.4_
  - [x] 3.2 체크포인트 - legacy-mig-case 파일 구조 및 내용 확인
    - 모든 파일이 올바르게 생성되었는지 확인, 문제가 있으면 사용자에게 질문

- [ ] 4. Module Case - 커스텀 모듈 작성
  - [x] 4.1 modules/networking/ 모듈 생성 (main.tf, variables.tf, outputs.tf)
    - VPC, Subnet, Internet Gateway, Route Table 리소스
    - 입력: environment, vpc_cidr, subnet_count, region
    - 출력: vpc_id, subnet_ids, public_subnet_ids
    - 한국어 주석 포함
    - _Requirements: 3.1, 3.3, 6.5_
  - [x] 4.2 modules/compute/ 모듈 생성 (main.tf, variables.tf, outputs.tf)
    - EC2 Instance, Security Group 리소스
    - 입력: environment, vpc_id, subnet_id, ami_id, instance_type
    - 출력: instance_id, public_ip, security_group_id
    - 한국어 주석 포함
    - _Requirements: 3.1, 3.3, 6.5_

- [ ] 5. Module Case - 루트 모듈 및 환경 설정
  - [x] 5.1 root/versions.tf 생성: 테라폼 및 프로바이더 버전 고정
    - _Requirements: 5.5_
  - [x] 5.2 root/provider.tf 생성: 프로바이더 및 백엔드 설정
    - _Requirements: 1.1, 1.2, 1.4, 5.1_
  - [x] 5.3 root/variables.tf 생성: 루트 모듈 변수 정의
    - _Requirements: 5.2_
  - [x] 5.4 root/main.tf 생성: 커스텀 모듈(networking, compute) + 레지스트리 모듈(terraform-aws-modules/s3-bucket/aws) 호출
    - networking 출력을 compute 입력으로 전달
    - 레지스트리 모듈에 특정 버전 문자열 고정 (version = "4.2.2")
    - 한국어 주석 포함
    - _Requirements: 3.2, 3.4, 3.5, 3.6, 6.5_
  - [x] 5.5 root/outputs.tf 생성: 최종 출력 정의
    - _Requirements: 5.3_
  - [x] 5.6 root/envs/ 디렉토리에 dev.tfvars, stg.tfvars, prd.tfvars 생성
    - _Requirements: 3.7, 1.5_

- [ ] 6. Module Case - README 및 체크포인트
  - [x] 6.1 module-case/README.md 생성: 모듈 구조, 사용 패턴, 버전 고정 전략 설명
    - 디렉토리 구조 다이어그램 포함
    - 커스텀 모듈 vs 레지스트리 모듈 설명
    - 사용법 설명
    - _Requirements: 3.8, 6.2, 6.3, 6.4_
  - [x] 6.2 체크포인트 - module-case 파일 구조 및 내용 확인
    - 모든 파일이 올바르게 생성되었는지 확인, 문제가 있으면 사용자에게 질문

- [ ] 7. Static Rising Case - 공통 파일 구성
  - [x] 7.1 resource/region1/account1/ 디렉토리에 terraform.tf, locals.tf, variables.tf, data.tf, main.tf, outputs.tf 생성
    - terraform.tf: 버전 고정 + S3 백엔드 (고유 key)
    - locals.tf: 프리픽스 네이밍 규칙, 태그 맵, 리소스 정의 맵 (for_each용)
    - variables.tf: 리전/계정별 변수
    - data.tf: aws_ami, aws_availability_zones 등 데이터 소스
    - main.tf: for_each로 VPC/Subnet 생성, dynamic 블록으로 Security Group 규칙 생성
    - outputs.tf: 출력 정의
    - 모든 파일에 한국어 주석 포함
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.8, 5.1, 5.2, 5.3, 5.5, 6.5_

- [ ] 8. Static Rising Case - 나머지 리전/계정 디렉토리
  - [x] 8.1 resource/region1/account2/ 디렉토리에 동일 구조 파일 생성 (리전/계정 값만 변경)
    - backend key, locals의 account 값, 변수 기본값 변경
    - _Requirements: 4.5, 4.8_
  - [x] 8.2 resource/region2/account2/ 디렉토리에 동일 구조 파일 생성 (리전 변경)
    - region을 us-west-1 등으로 변경, region_short 변경
    - _Requirements: 4.5, 4.8_
  - [x] 8.3 resource/region2/accouunt1/ 디렉토리에 동일 구조 파일 생성 (기존 오타 디렉토리명 유지)
    - _Requirements: 4.5, 4.8_

- [ ] 9. Static Rising Case - README 및 체크포인트
  - [x] 9.1 static-rising-case/README.md 생성: 네이밍 규칙, 디렉토리 구조, 테라폼 문법 패턴 설명
    - for_each, dynamic, locals, data sources 활용법 설명
    - 프리픽스 네이밍 규칙 설명
    - 사용법 설명
    - _Requirements: 4.7, 6.2, 6.3, 6.4_
  - [x] 9.2 체크포인트 - static-rising-case 파일 구조 및 내용 확인
    - 모든 파일이 올바르게 생성되었는지 확인, 문제가 있으면 사용자에게 질문

- [ ] 10. 루트 README 업데이트 및 최종 확인
  - [x] 10.1 루트 README.md 업데이트: 프로젝트 목적, 세 가지 케이스 설명, 공통 사항 안내
    - 각 케이스 간략 설명 및 링크
    - 공통 백엔드 설정 안내
    - _Requirements: 6.1_
  - [x] 10.2 최종 체크포인트 - 전체 프로젝트 구조 확인
    - 모든 케이스의 파일이 올바르게 생성되었는지 확인, 문제가 있으면 사용자에게 질문

## 참고

- 각 체크포인트에서 파일 구조와 내용을 검증합니다
- 모든 .tf 파일의 주석은 한국어로 작성합니다
- 실제 AWS 리소스를 생성하지 않지만, terraform validate가 통과하는 형태를 목표로 합니다
