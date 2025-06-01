import boto3
from datetime import datetime, timezone
from typing import List, Dict

def get_cloudfront_usage_and_cost(pricing: Dict) -> List[Dict]:
    cf = boto3.client("cloudfront")
    cw = boto3.client("cloudwatch")

    now = datetime.now(timezone.utc)
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)

    price_per_gb = pricing.get("CloudFront", {}).get("data_transfer_out_per_gb", 0.085)
    price_per_10k_req = pricing.get("CloudFront", {}).get("requests_per_10000", 0.0075)

    results = []
    distributions = cf.list_distributions().get("DistributionList", {}).get("Items", [])

    for dist in distributions:
        dist_id = dist["Id"]
        domain_name = dist["DomainName"]

        try:
            # 1. 요청 수
            req_metrics = cw.get_metric_statistics(
                Namespace="AWS/CloudFront",
                MetricName="Requests",
                Dimensions=[
                    {"Name": "DistributionId", "Value": dist_id},
                    {"Name": "Region", "Value": "Global"}
                ],
                StartTime=start,
                EndTime=now,
                Period=86400,
                Statistics=["Sum"]
            )
            request_count = req_metrics.get("Datapoints", [{}])[0].get("Sum", 0)

            # 2. 전송량
            transfer_metrics = cw.get_metric_statistics(
                Namespace="AWS/CloudFront",
                MetricName="BytesDownloaded",
                Dimensions=[
                    {"Name": "DistributionId", "Value": dist_id},
                    {"Name": "Region", "Value": "Global"}
                ],
                StartTime=start,
                EndTime=now,
                Period=86400,
                Statistics=["Sum"]
            )
            bytes_downloaded = transfer_metrics.get("Datapoints", [{}])[0].get("Sum", 0)
            gb_downloaded = bytes_downloaded / (1024 ** 3)

            # 비용 계산
            cost_req = (request_count / 10_000) * price_per_10k_req
            cost_transfer = gb_downloaded * price_per_gb
            total_cost = cost_req + cost_transfer

            results.append({
                "service": "CloudFront",
                "detail": f"{domain_name} - {int(request_count)} req / {gb_downloaded:.2f} GB",
                "cost": round(total_cost, 4)
            })

        except Exception as e:
            print(f"⚠️ CloudFront {dist_id} 수집 실패: {e}")
            continue

    return results

import boto3
from datetime import datetime, timezone
from typing import List, Dict

def get_cloudfront_usage_and_cost(pricing: Dict) -> List[Dict]:
    cf = boto3.client("cloudfront")
    cw = boto3.client("cloudwatch")

    now = datetime.now(timezone.utc)
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)

    price_per_gb = pricing.get("CloudFront", {}).get("data_transfer_out_per_gb", 0.085)
    price_per_10k_req = pricing.get("CloudFront", {}).get("requests_per_10000", 0.0075)

    results = []
    distributions = cf.list_distributions().get("DistributionList", {}).get("Items", [])

    for dist in distributions:
        dist_id = dist["Id"]
        domain_name = dist["DomainName"]

        try:
            # 1. 요청 수
            req_metrics = cw.get_metric_statistics(
                Namespace="AWS/CloudFront",
                MetricName="Requests",
                Dimensions=[
                    {"Name": "DistributionId", "Value": dist_id},
                    {"Name": "Region", "Value": "Global"}
                ],
                StartTime=start,
                EndTime=now,
                Period=86400,
                Statistics=["Sum"]
            )
            request_count = req_metrics.get("Datapoints", [{}])[0].get("Sum", 0)

            # 2. 전송량
            transfer_metrics = cw.get_metric_statistics(
                Namespace="AWS/CloudFront",
                MetricName="BytesDownloaded",
                Dimensions=[
                    {"Name": "DistributionId", "Value": dist_id},
                    {"Name": "Region", "Value": "Global"}
                ],
                StartTime=start,
                EndTime=now,
                Period=86400,
                Statistics=["Sum"]
            )
            bytes_downloaded = transfer_metrics.get("Datapoints", [{}])[0].get("Sum", 0)
            gb_downloaded = bytes_downloaded / (1024 ** 3)

            # 비용 계산
            cost_req = (request_count / 10_000) * price_per_10k_req
            cost_transfer = gb_downloaded * price_per_gb
            total_cost = cost_req + cost_transfer

            results.append({
                "service": "CloudFront",
                "detail": f"{domain_name} - {int(request_count)} req / {gb_downloaded:.2f} GB",
                "cost": round(total_cost, 4)
            })

        except Exception as e:
            print(f"⚠️ CloudFront {dist_id} 수집 실패: {e}")
            continue

    return results
