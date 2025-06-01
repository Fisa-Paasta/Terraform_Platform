# 📦 Lambda 서비스 구조 및 서비스 추가 가이드

이 디렉토리는 자동화된 AWS 리소스 운영/비용 모니터링을 위한 Lambda 함수들을 포함합니다.  
아직 AWS CLI 연동은 되어 있지 않으며, 구조 설계와 테스트 목적의 로직 구성을 중심으로 진행 중입니다.

---

## 📁 디렉토리 구조

<code>
lambda/
├── resource_manager/ # 리소스 종료/삭제 자동화
├── resource_log_collector/ # 리소스 로그 수집
├── usage_cost_monitor/ # 서비스별 일간 비용 계산
└── utils/ # 공통 Slack + Fallback 유틸
</code>

---

## Ⓜ️ make 명령어

-- help -> 사용 가능한 Make 명령어 출력
-- zip-all -> 모든 Lambda 함수 디렉토리를 압축
-- zip-one -> 선택한 Lambda 디렉토리만 압축
-- apply -> 특정 Terraform 모듈을 선택하여 init + apply 수행
-- deploy-all -> 모든 Lambda zip + 전체 Terraform 배포
-- destroy -> 특정 Terraform 모듈만 선택하여 destroy
-- destroy-all -> 전체 Terraform 모듈 삭제 (확인 포함)
-- plan -> 전체 Terraform 모듈 plan 실행
-- init -> 전체 Terraform 모듈 init 실행
-- validate -> 전체 Terraform 모듈 validate 실행
-- clean -> zip 파일 정리
-- test -> 로컬 테스트 핸들러 실행

## 🛠 서비스 추가 방법

### 1️⃣ `resource_manager`

| 단계 | 설명                                                                                                       |
| ---- | ---------------------------------------------------------------------------------------------------------- |
| 1    | `lambda/resource_manager/services/<service>.py` 파일 생성                                                  |
| 2    | `index.py`에 해당 서비스 `import` 및 함수 실행 등록                                                        |
| 3    | `main()` 안에서 `delete_<service>()` 등 실행 로직 추가                                                     |
| 4    | `terraform/resource_manager/main.tf`에 IAM 권한 추가<br/>예: `s3:ListBuckets`, `ec2:TerminateInstances` 등 |
| 5    | (선택) Slack 알림 포맷에 리소스명/결과 포함                                                                |

---

### 2️⃣ `resource_log_collector`

| 단계 | 설명                                                          |
| ---- | ------------------------------------------------------------- |
| 1    | 로그 수집 로직을 `index.py` 또는 `services/`에 추가           |
| 2    | 예: `collect_<service>_events()` 함수 정의                    |
| 3    | `index.py` 내 `main()`에서 해당 함수 호출                     |
| 4    | 필요한 `logs:GetLogEvents`, `DescribeLogGroups` IAM 권한 추가 |
| 5    | (선택) Slack으로 로그 핵심 요약 알림 전송 로직 추가           |

---

### 3️⃣ `usage_cost_monitor`

| 단계 | 설명                                                                                                                        |
| ---- | --------------------------------------------------------------------------------------------------------------------------- |
| 1    | `lambda/usage_cost_monitor/services/<service>.py` 생성<br/>→ 반드시 `get_<service>_usage_and_cost(pricing: dict)` 함수 포함 |
| 2    | `handler.py`에 해당 모듈 `import` 및 `service_modules` 리스트에 등록                                                        |
| 3    | (선택) `pricing/static_pricing.json`에 해당 서비스 요금 정보 추가                                                           |
| 4    | IAM 권한은 대부분 `Describe`, `List` 수준으로 충분                                                                          |

---

## 📎 참고

- Slack 전송 실패 시 SNS Fallback을 통해 이메일 등으로 알림 전송됨 (`utils/slack.py`)
- 모든 Lambda는 Terraform으로 모듈화되어 관리됨 (`terraform/*`)
- Lambda ZIP 파일은 `make zip-all` 명령으로 자동 생성됨 (`packages/` 저장)

---

✅ **서비스를 하나 추가할 때는 위의 단계를 체크리스트처럼 따라가세요.**  
❌ 실수로 handler에 등록하지 않거나, IAM을 누락하면 실행 시 에러 발생합니다.
