import boto3
from datetime import datetime, timezone
from typing import List, Dict

def get_eks_usage_and_cost(pricing: Dict) -> List[Dict]:
    eks = boto3.client("eks")
    clusters = eks.list_clusters().get("clusters", [])

    price_per_hour = pricing.get("EKS", {}).get("cluster_hourly", 0.10)
    results = []

    now = datetime.now(timezone.utc)
    start_of_day = now.replace(hour=0, minute=0, second=0, microsecond=0)
    usage_hours = (now - start_of_day).total_seconds() / 3600

    for cluster_name in clusters:
        try:
            cluster_info = eks.describe_cluster(name=cluster_name)["cluster"]
            status = cluster_info.get("status", "UNKNOWN")

            if status != "ACTIVE":
                continue

            cost = price_per_hour * usage_hours

            results.append({
                "service": "EKS",
                "detail": f"{cluster_name} - {usage_hours:.1f}시간",
                "cost": round(cost, 4)
            })

        except Exception as e:
            continue  # 클러스터 조회 실패시 skip

    return results
