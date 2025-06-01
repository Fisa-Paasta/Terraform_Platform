import boto3
from datetime import datetime, timezone
from typing import List, Dict

def get_waf_usage_and_cost(pricing: Dict) -> List[Dict]:
    waf = boto3.client("wafv2")
    cw = boto3.client("cloudwatch")

    now = datetime.now(timezone.utc)
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)

    price_acl_hourly = pricing.get("WAF", {}).get("web_acl_per_hour", 0.60)
    price_per_million_req = pricing.get("WAF", {}).get("request_per_million", 0.60)

    results = []

    # WAF는 Scope: CLOUDFRONT | REGIONAL
    for scope in ["REGIONAL", "CLOUDFRONT"]:
        try:
            response = waf.list_web_acls(Scope=scope)
            web_acls = response.get("WebACLs", [])

            for acl in web_acls:
                name = acl["Name"]
                metric_name = acl["MetricName"]
                id = acl["Id"]

                # 요청 수 집계
                metrics = cw.get_metric_statistics(
                    Namespace="AWS/WAFV2",
                    MetricName="AllowedRequests",
                    Dimensions=[
                        {"Name": "WebACL", "Value": name},
                        {"Name": "Region", "Value": "Global" if scope == "CLOUDFRONT" else boto3.Session().region_name}
                    ],
                    StartTime=start,
                    EndTime=now,
                    Period=86400,
                    Statistics=["Sum"]
                )

                req_count = metrics.get("Datapoints", [{}])[0].get("Sum", 0)
                cost_acl = price_acl_hourly * ((now - start).total_seconds() / 3600)
                cost_req = (req_count / 1_000_000) * price_per_million_req
                total = cost_acl + cost_req

                results.append({
                    "service": "WAF",
                    "detail": f"{name} ({scope}) - {int(req_count)} req",
                    "cost": round(total, 4)
                })

        except Exception as e:
            print(f"⚠️ WAF ({scope}) 처리 중 오류: {e}")
            continue

    return results

import boto3
from datetime import datetime, timezone
from typing import List, Dict

def get_waf_usage_and_cost(pricing: Dict) -> List[Dict]:
    waf = boto3.client("wafv2")
    cw = boto3.client("cloudwatch")

    now = datetime.now(timezone.utc)
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)

    price_acl_hourly = pricing.get("WAF", {}).get("web_acl_per_hour", 0.60)
    price_per_million_req = pricing.get("WAF", {}).get("request_per_million", 0.60)

    results = []

    # WAF는 Scope: CLOUDFRONT | REGIONAL
    for scope in ["REGIONAL", "CLOUDFRONT"]:
        try:
            response = waf.list_web_acls(Scope=scope)
            web_acls = response.get("WebACLs", [])

            for acl in web_acls:
                name = acl["Name"]
                metric_name = acl["MetricName"]
                id = acl["Id"]

                # 요청 수 집계
                metrics = cw.get_metric_statistics(
                    Namespace="AWS/WAFV2",
                    MetricName="AllowedRequests",
                    Dimensions=[
                        {"Name": "WebACL", "Value": name},
                        {"Name": "Region", "Value": "Global" if scope == "CLOUDFRONT" else boto3.Session().region_name}
                    ],
                    StartTime=start,
                    EndTime=now,
                    Period=86400,
                    Statistics=["Sum"]
                )

                req_count = metrics.get("Datapoints", [{}])[0].get("Sum", 0)
                cost_acl = price_acl_hourly * ((now - start).total_seconds() / 3600)
                cost_req = (req_count / 1_000_000) * price_per_million_req
                total = cost_acl + cost_req

                results.append({
                    "service": "WAF",
                    "detail": f"{name} ({scope}) - {int(req_count)} req",
                    "cost": round(total, 4)
                })

        except Exception as e:
            print(f"⚠️ WAF ({scope}) 처리 중 오류: {e}")
            continue

    return results
