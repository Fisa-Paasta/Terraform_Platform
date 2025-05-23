import boto3
from datetime import datetime
from typing import List, Dict

def get_sns_usage_and_cost(pricing: Dict) -> List[Dict]:
    cw = boto3.client("cloudwatch")
    sns = boto3.client("sns")

    start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    end = datetime.utcnow()

    price_per_million = pricing.get("SNS", {}).get("publish_per_million", 0.50)

    topics = sns.list_topics().get("Topics", [])
    results = []

    for topic in topics:
        topic_arn = topic["TopicArn"]
        topic_name = topic_arn.split(":")[-1]

        try:
            metrics = cw.get_metric_statistics(
                Namespace="AWS/SNS",
                MetricName="NumberOfMessagesPublished",
                Dimensions=[{"Name": "TopicName", "Value": topic_name}],
                StartTime=start,
                EndTime=end,
                Period=86400,
                Statistics=["Sum"]
            )

            count = metrics.get("Datapoints", [{}])[0].get("Sum", 0)

            if count > 0:
                cost = (count / 1_000_000) * price_per_million
                results.append({
                    "service": "SNS",
                    "detail": f"{topic_name} - {int(count)}회 발행",
                    "cost": round(cost, 4)
                })

        except Exception:
            continue

    return results
