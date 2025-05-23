import boto3
from datetime import datetime, timedelta
from typing import List, Dict

def get_lambda_usage_and_cost(pricing: Dict) -> List[Dict]:
    cw = boto3.client("cloudwatch")
    lambda_client = boto3.client("lambda")

    start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    end = datetime.utcnow()

    price_per_million = pricing.get("Lambda", {}).get("per_1m_invocations", 0.20)
    price_per_gb_second = pricing.get("Lambda", {}).get("per_gb_second", 0.00001667)

    results = []

    functions = lambda_client.list_functions()["Functions"]
    for fn in functions:
        fn_name = fn["FunctionName"]
        memory_mb = fn.get("MemorySize", 128)

        # 호출 횟수
        invoc_metrics = cw.get_metric_statistics(
            Namespace="AWS/Lambda",
            MetricName="Invocations",
            Dimensions=[{"Name": "FunctionName", "Value": fn_name}],
            StartTime=start,
            EndTime=end,
            Period=86400,
            Statistics=["Sum"]
        )

        # 실행시간 (ms)
        duration_metrics = cw.get_metric_statistics(
            Namespace="AWS/Lambda",
            MetricName="Duration",
            Dimensions=[{"Name": "FunctionName", "Value": fn_name}],
            StartTime=start,
            EndTime=end,
            Period=86400,
            Statistics=["Sum"]
        )

        invocations = invoc_metrics.get("Datapoints", [{}])[0].get("Sum", 0)
        total_duration_ms = duration_metrics.get("Datapoints", [{}])[0].get("Sum", 0)

        # GB-sec 계산
        gb_sec = (memory_mb / 1024) * (total_duration_ms / 1000)

        # 비용 계산
        cost_invoc = (invocations / 1_000_000) * price_per_million
        cost_duration = gb_sec * price_per_gb_second
        total_cost = cost_invoc + cost_duration

        if total_cost > 0:
            results.append({
                "service": "Lambda",
                "detail": f"{fn_name} - {int(invocations)}회, {gb_sec:.2f}GB-sec",
                "cost": round(total_cost, 4)
            })

    return results
