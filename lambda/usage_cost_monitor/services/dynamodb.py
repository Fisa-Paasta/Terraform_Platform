import boto3
from datetime import datetime, timedelta
from typing import List, Dict

def get_dynamodb_usage_and_cost(pricing: Dict) -> List[Dict]:
    cw = boto3.client("cloudwatch")
    ddb = boto3.client("dynamodb")

    now = datetime.utcnow()
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    end = now

    price_per_wcu = pricing.get("DynamoDB", {}).get("write_request_unit_per_million", 1.50)
    price_per_rcu = pricing.get("DynamoDB", {}).get("read_request_unit_per_million", 0.30)

    tables = ddb.list_tables().get("TableNames", [])
    results = []

    for table_name in tables:
        try:
            write_metrics = cw.get_metric_statistics(
                Namespace="AWS/DynamoDB",
                MetricName="WriteRequestUnits",
                Dimensions=[{"Name": "TableName", "Value": table_name}],
                StartTime=start,
                EndTime=end,
                Period=86400,
                Statistics=["Sum"]
            )
            read_metrics = cw.get_metric_statistics(
                Namespace="AWS/DynamoDB",
                MetricName="ReadRequestUnits",
                Dimensions=[{"Name": "TableName", "Value": table_name}],
                StartTime=start,
                EndTime=end,
                Period=86400,
                Statistics=["Sum"]
            )

            wcu = write_metrics.get("Datapoints", [{}])[0].get("Sum", 0)
            rcu = read_metrics.get("Datapoints", [{}])[0].get("Sum", 0)

            cost_wcu = (wcu / 1_000_000) * price_per_wcu
            cost_rcu = (rcu / 1_000_000) * price_per_rcu
            total = cost_wcu + cost_rcu

            if total > 0:
                results.append({
                    "service": "DynamoDB",
                    "detail": f"{table_name} - {int(rcu)} RCU / {int(wcu)} WCU",
                    "cost": round(total, 4)
                })

        except Exception:
            continue

    return results
