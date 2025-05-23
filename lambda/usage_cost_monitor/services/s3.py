import boto3
from datetime import datetime, timedelta
from typing import List, Dict

def get_s3_usage_and_cost(pricing: Dict) -> List[Dict]:
    cloudwatch = boto3.client("cloudwatch")
    s3 = boto3.client("s3")

    price_per_gb = pricing.get("S3", {}).get("standard_storage_per_gb_month", 0.023)

    # 오늘의 시작 시간 (UTC 기준)
    end = datetime.utcnow()
    start = end - timedelta(days=1)

    buckets = s3.list_buckets().get("Buckets", [])
    results = []

    for bucket in buckets:
        bucket_name = bucket["Name"]

        try:
            metrics = cloudwatch.get_metric_statistics(
                Namespace="AWS/S3",
                MetricName="BucketSizeBytes",
                Dimensions=[
                    {"Name": "BucketName", "Value": bucket_name},
                    {"Name": "StorageType", "Value": "StandardStorage"}
                ],
                StartTime=start,
                EndTime=end,
                Period=86400,
                Statistics=["Average"]
            )

            datapoints = metrics.get("Datapoints", [])
            if not datapoints:
                continue  # 데이터가 없으면 skip

            avg_bytes = datapoints[0]["Average"]
            size_gb = avg_bytes / (1024 ** 3)

            # 월 기준 요금 → 하루 요금 계산
            cost = (size_gb * price_per_gb) / 30

            results.append({
                "service": "S3",
                "detail": f"{bucket_name}: {size_gb:.2f}GB",
                "cost": round(cost, 4)
            })

        except Exception as e:
            # 개별 버킷 에러 무시하고 진행
            continue

    return results
