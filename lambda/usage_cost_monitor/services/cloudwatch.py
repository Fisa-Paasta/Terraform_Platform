import boto3
from datetime import datetime, timezone
from typing import List, Dict

def get_cloudwatch_usage_and_cost(pricing: Dict) -> List[Dict]:
    logs = boto3.client("logs")
    now = datetime.now(timezone.utc)
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)

    price_ingest_per_gb = pricing.get("CloudWatch", {}).get("logs_ingest_per_gb", 0.50)
    price_storage_per_gb_month = pricing.get("CloudWatch", {}).get("logs_storage_per_gb_month", 0.03)

    results = []

    groups = logs.describe_log_groups().get("logGroups", [])
    for group in groups:
        name = group["logGroupName"]
        stored_bytes = group.get("storedBytes", 0)
        storage_gb = stored_bytes / (1024 ** 3)
        storage_cost = (storage_gb * price_storage_per_gb_month) / 30

        # ingestion 은 metric filter 기반 추정 필요 → 여기선 가정/보완 처리
        # 최근 1일 logEvents 수를 기반 추정 (정확치 않음, optional)
        try:
            metrics = logs.describe_query_definitions()
            # 위는 custom metric 관련 → 생략 가능
        except:
            pass

        # 보수적으로 ingestion 0.0 GB (추정 어려움 시 생략)
        ingestion_gb = 0.0
        ingestion_cost = ingestion_gb * price_ingest_per_gb

        total = storage_cost + ingestion_cost

        results.append({
            "service": "CloudWatch",
            "detail": f"{name} - 저장: {storage_gb:.2f}GB",
            "cost": round(total, 4)
        })

    return results
