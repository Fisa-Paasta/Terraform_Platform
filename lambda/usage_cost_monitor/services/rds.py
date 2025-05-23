import boto3
from datetime import datetime, timezone
from typing import List, Dict

def get_rds_usage_and_cost(pricing: Dict) -> List[Dict]:
    rds = boto3.client("rds")
    now = datetime.now(timezone.utc)
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    usage_hours = (now - start).total_seconds() / 3600

    rds_prices = pricing.get("RDS", {}).get("instance_hourly", {})
    storage_price_per_gb = pricing.get("RDS", {}).get("storage_per_gb_month", 0.115)

    results = []

    instances = rds.describe_db_instances().get("DBInstances", [])
    for db in instances:
        db_id = db["DBInstanceIdentifier"]
        db_class = db["DBInstanceClass"]  # 예: db.t3.medium
        allocated_storage = db["AllocatedStorage"]  # GB

        hourly_price = rds_prices.get(db_class, 0.067)
        compute_cost = usage_hours * hourly_price
        storage_cost = (allocated_storage * storage_price_per_gb) / 30

        total_cost = compute_cost + storage_cost

        results.append({
            "service": "RDS",
            "detail": f"{db_id} ({db_class}) - {allocated_storage}GB",
            "cost": round(total_cost, 4)
        })

    return results
