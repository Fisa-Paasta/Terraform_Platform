import boto3
from datetime import datetime, timedelta
from typing import List, Dict

def estimate_running_hours(instance_id: str) -> float:
    cloudwatch = boto3.client("cloudwatch")
    now = datetime.utcnow()
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)

    metrics = cloudwatch.get_metric_statistics(
        Namespace="AWS/EC2",
        MetricName="CPUUtilization",
        Dimensions=[{"Name": "InstanceId", "Value": instance_id}],
        StartTime=start,
        EndTime=now,
        Period=3600,
        Statistics=["Average"]
    )

    datapoints = metrics.get("Datapoints", [])
    return len(datapoints)

def get_ec2_usage_and_cost(pricing: Dict) -> List[Dict]:
    ec2 = boto3.client("ec2")
    instances = ec2.describe_instances()
    results = []

    ec2_prices = pricing.get("EC2", {})

    for reservation in instances.get("Reservations", []):
        for instance in reservation.get("Instances", []):
            instance_id = instance.get("InstanceId")
            instance_type = instance.get("InstanceType")
            state = instance.get("State", {}).get("Name")

            if state != "running":
                continue

            price_per_hour = ec2_prices.get(instance_type, 0.1)
            usage_hours = estimate_running_hours(instance_id)
            cost = price_per_hour * usage_hours

            results.append({
                "service": "EC2",
                "detail": f"{instance_type} ({instance_id}) - {usage_hours:.0f}시간",
                "cost": round(cost, 4)
            })

    return results
