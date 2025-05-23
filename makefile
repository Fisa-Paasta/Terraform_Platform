.PHONY: help zip-all zip-one deploy-all apply destroy destroy-all plan init validate clean test

# ===========================
# 변수 정의
# ===========================

LAMBDA_NAMES := $(shell find lambda -mindepth 1 -maxdepth 1 -type d ! -name utils -exec basename {} \;)
PACKAGE_DIR := packages
MODULES := terraform/resource_manager terraform/log_collector terraform/cost_monitor terraform/usage_cost_monitor

# ===========================
# 도움말
# ===========================

help:  ## 사용 가능한 Make 명령어 출력
	@echo "Available Make commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' Makefile | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "-- %-16s -> %s\n", $$1, $$2}'

# ===========================
# Lambda 패키징
# ===========================

zip-all:  ## 모든 Lambda 함수 디렉토리를 압축
	@echo "Zipping all Lambda functions..."
	@mkdir -p $(PACKAGE_DIR)
	@for name in $(LAMBDA_NAMES); do \
		echo "-> Zipping $$name..."; \
		zip -r $(PACKAGE_DIR)/$$name.zip lambda/$$name lambda/utils > /dev/null; \
	done
	@echo "All Lambda zipped."

zip-one:  ## 선택한 Lambda 디렉토리만 압축
	@echo "Select a Lambda directory to zip:"
	@select name in $(LAMBDA_NAMES); do \
		if [ -n "$$name" ]; then \
			echo "Zipping $$name..."; \
			zip -r $(PACKAGE_DIR)/$$name.zip lambda/$$name lambda/utils; \
			echo "$$name zipped."; \
			break; \
		else \
			echo "Invalid selection. Try again."; \
		fi \
	done

# ===========================
# Terraform 명령어
# ===========================

apply:  ## 특정 Terraform 모듈을 선택하여 init + apply 수행
	@echo "Select a module to apply:"
	@select module in $(MODULES); do \
		if [ -n "$$module" ]; then \
			cd $$module && terraform init -input=false && terraform apply -auto-approve && cd - > /dev/null; \
			break; \
		else \
			echo "Invalid selection. Try again."; \
		fi \
	done

deploy-all: zip-all  ## 모든 Lambda zip + 전체 Terraform 배포
	@echo "Deploying all Terraform modules..."
	@for module in $(MODULES); do \
		echo "-> Deploying $$module..."; \
		cd $$module && terraform init -input=false && terraform apply -auto-approve && cd - > /dev/null; \
	done
	@echo "All modules deployed."

destroy:  ## 특정 Terraform 모듈만 선택하여 destroy
	@echo "Select a module to destroy:"
	@select module in $(MODULES); do \
		if [ -n "$$module" ]; then \
			cd $$module && terraform init -input=false > /dev/null && terraform plan -destroy; \
			read -p "Really destroy $$module? (yes/no): " confirm; \
			if [ "$$confirm" = "yes" ]; then \
				terraform destroy -auto-approve; \
			else \
				echo "Destroy cancelled."; \
			fi; \
			cd - > /dev/null; \
			break; \
		else \
			echo "Invalid selection. Try again."; \
		fi \
	done

destroy-all:  ## 전체 Terraform 모듈 삭제 (확인 포함)
	@echo "Destroying all modules..."
	@for module in $(MODULES); do \
		cd $$module && terraform init -input=false > /dev/null && terraform plan -destroy && cd - > /dev/null; \
	done
	@read -p "Really destroy ALL modules? This cannot be undone. (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		for module in $(MODULES); do \
			cd $$module && terraform destroy -auto-approve && cd - > /dev/null; \
		done; \
		echo "All modules destroyed."; \
	else \
		echo "Destroy-all cancelled."; \
	fi

plan: zip-all  ## 전체 Terraform 모듈 plan 실행
	@for module in $(MODULES); do \
		echo "Planning $$module..."; \
		cd $$module && terraform plan && cd - > /dev/null; \
	done

init:  ## 전체 Terraform 모듈 init 실행
	@for module in $(MODULES); do \
		echo "Initializing $$module..."; \
		cd $$module && terraform init && cd - > /dev/null; \
	done

validate:  ## 전체 Terraform 모듈 validate 실행
	@for module in $(MODULES); do \
		echo "Validating $$module..."; \
		cd $$module && terraform validate && cd - > /dev/null; \
	done

clean:  ## zip 파일 정리
	@echo "Cleaning zipped packages..."
	@rm -f $(PACKAGE_DIR)/*.zip
	@echo "Clean complete."

# ===========================
# 테스트
# ===========================

test:  ## 로컬 테스트 핸들러 실행
	@echo "Running local test handler..."
	python3 lambda/usage_cost_monitor/handler.py
