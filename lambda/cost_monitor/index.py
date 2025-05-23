from utils.slack import send_slack
import boto3
from datetime import datetime
import os

def lambda_handler(event, context):
    try:
        ce = boto3.client("ce")
        start = datetime.today().replace(day=1).strftime("%Y-%m-%d")
        end = datetime.today().strftime("%Y-%m-%d")

        res = ce.get_cost_and_usage(
            TimePeriod={"Start": start, "End": end},
            Granularity="MONTHLY",
            Metrics=["UnblendedCost"],
            GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}]
        )

        groups = res["ResultsByTime"][0]["Groups"]
        total = float(res["ResultsByTime"][0]["Total"]["UnblendedCost"]["Amount"])

        summary = "\n".join(
            f"- {g['Keys'][0]}: ${float(g['Metrics']['UnblendedCost']['Amount']):,.2f}"
            for g in groups
        )
        message = f"💰 *{start} ~ {end} 비용 요약:*\n{summary}\n\n📦 *총 비용: ${total:,.2f}*"
        send_slack(message, title="📊 비용 모니터링 결과")

    except Exception as e:
        send_slack(f"❌ 비용 모니터링 중 오류:\n```\n{str(e)}\n```", title="🚨 비용 모니터링 오류")
