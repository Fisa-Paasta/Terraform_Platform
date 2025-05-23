import boto3
from datetime import datetime, timezone
from typing import List, Dict

def get_route53_usage_and_cost(pricing: Dict) -> List[Dict]:
    r53 = boto3.client("route53")
    cw = boto3.client("cloudwatch")

    now = datetime.now(timezone.utc)
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)

    price_zone_monthly = pricing.get("Route53", {}).get("hosted_zone_per_month", 0.50)
    price_dns_per_million = pricing.get("Route53", {}).get("dns_queries_per_million", 0.40)

    results = []

    zones = r53.list_hosted_zones().get("HostedZones", [])
    total_zone_cost = 0
    total_query_cost = 0

    for zone in zones:
        zone_id = zone["Id"].split("/")[-1]
        zone_name = zone["Name"]
        is_private = zone.get("Config", {}).get("PrivateZone", False)

        # 호스팅 비용 계산 (일일로 환산)
        zone_cost = price_zone_monthly / 30
        total_zone_cost += zone_cost

        if not is_private:
            # Public Zone만 쿼리 측정
            try:
                metrics = cw.get_metric_statistics(
                    Namespace="AWS/Route53",
                    MetricName="DNSQueries",
                    Dimensions=[{"Name": "HostedZoneId", "Value": zone_id}],
                    StartTime=start,
                    EndTime=now,
                    Period=86400,
                    Statistics=["Sum"]
                )

                query_count = metrics.get("Datapoints", [{}])[0].get("Sum", 0)
                query_cost = (query_count / 1_000_000) * price_dns_per_million
                total_query_cost += query_cost

                results.append({
                    "service": "Route53",
                    "detail": f"{zone_name} - {int(query_count)} 쿼리",
                    "cost": round(zone_cost + query_cost, 4)
                })

            except Exception as e:
                results.append({
                    "service": "Route53",
                    "detail": f"{zone_name} - 쿼리 수집 실패",
                    "cost": round(zone_cost, 4)
                })
        else:
            # Private Zone은 쿼리 측정 없음
            results.append({
                "service": "Route53",
                "detail": f"{zone_name} (Private)",
                "cost": round(zone_cost, 4)
            })

    return results
