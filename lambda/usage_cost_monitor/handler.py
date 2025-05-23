import json
from datetime import datetime

from services.ec2 import get_ec2_usage_and_cost
from services.eks import get_eks_usage_and_cost
from services.s3 import get_s3_usage_and_cost
from services.lambda_fn import get_lambda_usage_and_cost
from services.dynamodb import get_dynamodb_usage_and_cost
from services.rds import get_rds_usage_and_cost
from services.sns import get_sns_usage_and_cost
from services.waf import get_waf_usage_and_cost
from services.route53 import get_route53_usage_and_cost
from services.cloudfront import get_cloudfront_usage_and_cost
from services.cloudwatch import get_cloudwatch_usage_and_cost

from utils.slack import send_slack

# 요금 정보 로딩
with open("pricing/static_pricing.json") as f:
    PRICING = json.load(f)

def lambda_handler(event, context):
    try:
        all_results = []
        total_cost = 0.0

        service_modules = [
            get_ec2_usage_and_cost,
            get_eks_usage_and_cost,
            get_s3_usage_and_cost,
            get_lambda_usage_and_cost,
            get_dynamodb_usage_and_cost,
            get_rds_usage_and_cost,
            get_sns_usage_and_cost,
            get_waf_usage_and_cost,
            get_route53_usage_and_cost,
            get_cloudfront_usage_and_cost,
            get_cloudwatch_usage_and_cost,
        ]

        for service_func in service_modules:
            try:
                usage_data = service_func(PRICING)
                if usage_data:
                    all_results.extend(usage_data)
                    total_cost += sum(item["cost"] for item in usage_data)
            except Exception as service_error:
                print(f"[WARN] {service_func.__name__} 처리 중 오류 발생: {service_error}")
                continue

        today = datetime.utcnow().strftime("%Y-%m-%d")
        body = "\n".join(
            f"- {item['service']} ({item.get('detail', '')}): ${item['cost']:.4f}"
            for item in all_results
        )

        message = f"*{today} 리소스 사용량 비용 요약:*\n{body}\n\n총합: ${total_cost:.4f}"
        send_slack(message, title="일간 리소스 비용 모니터링")

    except Exception as e:
        send_slack(f"비용 계산 중 오류:\n```\n{str(e)}\n```", title="비용 계산 오류")

# ================================
# 로컬 테스트 진입점
# ================================
if __name__ == "__main__":
    print("[INFO] 로컬 테스트 모드 실행 중...")
    try:
        lambda_handler(event=None, context=None)
        print("[INFO] 테스트 완료.")
    except Exception as e:
        print(f"[ERROR] 로컬 테스트 중 예외 발생: {e}")
