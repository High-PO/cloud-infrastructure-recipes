# 요구사항 문서

## 소개

테라폼(Terraform) 인프라 코드를 케이스별로 정리하는 예제 프로젝트입니다. 레거시 마이그레이션, 모듈 활용, 스태틱 라이징 세 가지 케이스를 통해 테라폼 코드 구성의 다양한 패턴과 모범 사례를 보여줍니다.

## 용어 정의

- **Workspace**: 테라폼 워크스페이스. 동일 코드베이스에서 환경(dev/stg/prd)을 분리하는 메커니즘
- **Backend**: 테라폼 상태 파일(tfstate)을 저장하는 원격 저장소. 본 프로젝트에서는 S3 + DynamoDB 조합 사용
- **Provider**: 테라폼이 인프라를 관리하기 위해 사용하는 플러그인. 본 프로젝트에서는 AWS Provider 사용
- **Module**: 테라폼 리소스를 재사용 가능한 단위로 묶은 패키지
- **Registry_Module**: HashiCorp 테라폼 레지스트리에 공개된 커뮤니티/공식 모듈
- **Custom_Module**: 프로젝트 내부에서 직접 작성한 로컬 모듈
- **Legacy_Migration**: 단일 main.tf에 모든 리소스가 집중된 레거시 구조를 파일별/환경별로 분리하는 과정
- **Static_Rising**: 모듈을 사용하지 않고 테라폼 내장 문법(for_each, dynamic, locals, data sources 등)을 극대화하여 코드를 구성하는 패턴
- **Prefix_Naming**: 리소스 이름에 환경/리전/계정 등의 접두사를 체계적으로 부여하는 네이밍 규칙

## 요구사항

### 요구사항 1: 공통 인프라 구성

**사용자 스토리:** 인프라 엔지니어로서, 모든 케이스에서 일관된 백엔드 및 프로바이더 설정을 사용하고 싶다. 이를 통해 케이스 간 전환이 용이하고 상태 관리가 안전하게 이루어진다.

#### 수용 기준

1. THE Backend_Configuration SHALL use S3 as the state storage and DynamoDB as the state locking mechanism
2. THE Provider_Configuration SHALL specify the AWS Provider with an explicit version constraint
3. WHEN a Workspace is used, THE Backend_Configuration SHALL include the workspace name in the S3 key path to isolate state per environment
4. THE Provider_Configuration SHALL define the AWS region using a variable to allow multi-region deployment
5. WHEN multiple environments exist, THE Workspace SHALL separate environment-specific configurations using terraform.workspace or tfvars files

### 요구사항 2: 레거시 마이그레이션 케이스

**사용자 스토리:** 인프라 엔지니어로서, 단일 main.tf에 모든 리소스가 집중된 레거시 코드를 파일별/환경별로 분리하는 마이그레이션 과정을 참고하고 싶다. 이를 통해 실제 레거시 코드 리팩토링 시 단계별 가이드로 활용할 수 있다.

#### 수용 기준

1. THE Legacy_Migration_Before SHALL contain a single main.tf file with all resources (VPC, Subnet, Security Group, EC2, S3, IAM) defined together
2. THE Legacy_Migration_Before SHALL contain a single variables.tf file with all variables defined without environment separation
3. THE Legacy_Migration_After SHALL separate resources into individual files by resource type (vpc.tf, ec2.tf, s3.tf, iam.tf)
4. THE Legacy_Migration_After SHALL separate variables into environment-specific tfvars files (dev.tfvars, stg.tfvars, prd.tfvars)
5. THE Legacy_Migration_After SHALL include an outputs.tf file that exports key resource attributes
6. THE Legacy_Migration_After SHALL include a versions.tf file that pins provider and terraform version constraints
7. THE Legacy_Migration_Case SHALL include a README.md that explains the before/after structure and migration steps in Korean

### 요구사항 3: 모듈 케이스

**사용자 스토리:** 인프라 엔지니어로서, 커스텀 모듈과 레지스트리 모듈을 혼합 사용하는 모범 사례를 참고하고 싶다. 이를 통해 재사용 가능하고 버전 관리가 명확한 인프라 코드를 작성할 수 있다.

#### 수용 기준

1. THE Module_Case SHALL include at least one Custom_Module with input variables, output values, and a README.md
2. THE Module_Case SHALL include at least one Registry_Module call with an explicit version constraint using the version argument
3. THE Custom_Module SHALL follow the standard module structure (main.tf, variables.tf, outputs.tf)
4. WHEN a Registry_Module is called, THE Module_Case SHALL pin the module version using a specific version string rather than a range
5. THE Module_Case SHALL demonstrate passing outputs from one module as inputs to another module
6. THE Module_Case SHALL include a root module that orchestrates Custom_Module and Registry_Module calls
7. THE Module_Case SHALL include environment-specific tfvars files (dev.tfvars, stg.tfvars, prd.tfvars) for the root module
8. THE Module_Case SHALL include a README.md that explains the module structure, usage patterns, and version pinning strategy in Korean

### 요구사항 4: 스태틱 라이징 케이스

**사용자 스토리:** 인프라 엔지니어로서, 모듈 없이 테라폼 내장 문법만으로 코드를 효율적으로 구성하는 패턴을 참고하고 싶다. 이를 통해 for_each, dynamic, locals, data sources 등의 활용법을 익힐 수 있다.

#### 수용 기준

1. THE Static_Rising_Case SHALL use for_each to create multiple similar resources from a single resource block
2. THE Static_Rising_Case SHALL use dynamic blocks to generate repeatable nested blocks within resources
3. THE Static_Rising_Case SHALL use locals to define computed values and Prefix_Naming conventions
4. THE Static_Rising_Case SHALL use data sources to reference existing AWS resources
5. THE Static_Rising_Case SHALL organize code under the existing region/account directory structure (resource/region/account)
6. THE Static_Rising_Case SHALL apply consistent Prefix_Naming using the format "${environment}-${region}-${account}-${resource_type}"
7. THE Static_Rising_Case SHALL include a README.md that explains the naming conventions, directory structure, and terraform syntax patterns used in Korean
8. WHEN resources span multiple regions and accounts, THE Static_Rising_Case SHALL maintain separate state files per region-account combination

### 요구사항 5: 파일 분리 및 구조화

**사용자 스토리:** 인프라 엔지니어로서, 각 케이스에서 파일이 역할별로 명확히 분리되어 있기를 원한다. 이를 통해 코드 가독성과 유지보수성이 향상된다.

#### 수용 기준

1. WHEN terraform configuration is created, THE File_Structure SHALL separate provider and backend configuration into a dedicated file (provider.tf or versions.tf)
2. WHEN terraform configuration is created, THE File_Structure SHALL separate variable declarations into variables.tf
3. WHEN terraform configuration is created, THE File_Structure SHALL separate output declarations into outputs.tf
4. WHEN terraform configuration is created, THE File_Structure SHALL separate resource definitions by logical grouping (e.g., networking, compute, storage)
5. THE File_Structure SHALL include terraform.tf or versions.tf for terraform and provider version constraints in every deployable directory

### 요구사항 6: 문서화

**사용자 스토리:** 인프라 엔지니어로서, 각 케이스의 목적, 구조, 사용법이 한국어로 문서화되어 있기를 원한다. 이를 통해 팀원들이 빠르게 이해하고 활용할 수 있다.

#### 수용 기준

1. THE Root_README SHALL describe the overall project purpose and list all three cases with brief descriptions in Korean
2. THE Case_README SHALL include a directory structure diagram showing the file layout of the case
3. THE Case_README SHALL include usage instructions explaining how to initialize and apply the terraform configuration
4. THE Case_README SHALL include key concepts or patterns demonstrated in the case
5. WHEN code comments are written, THE Comments SHALL be in Korean to maintain consistency with documentation
