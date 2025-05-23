import os
import json
import urllib.request
import boto3
from datetime import datetime

SLACK_WEBHOOK = os.environ.get("SLACK_WEBHOOK")
FALLBACK_SNS = os.environ.get("FALLBACK_SNS")

def send_slack(message: str, title: str = "📢 Paasta 리소스 관리 알림"):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    payload = {
        "blocks": [
            {
                "type": "header",
                "text": { "type": "plain_text", "text": title }
            },
            {
                "type": "section",
                "text": { "type": "mrkdwn", "text": f"*📅 {timestamp}*\n\n{message}" }
            }
        ]
    }

    try:
        req = urllib.request.Request(
            SLACK_WEBHOOK,
            data=json.dumps(payload).encode("utf-8"),
            headers={ "Content-Type": "application/json" }
        )
        urllib.request.urlopen(req)
        print("✅ Slack 알림 전송 완료")

    except Exception as e:
        print(f"❌ Slack 전송 실패: {e}")
        fallback_message = f"{message}\n\n⚠️ Slack 전송 실패 원인:\n```{str(e)}```"
        _fallback_to_sns(f"[FALLBACK] {title}", fallback_message)

def _fallback_to_sns(subject: str, message: str):
    if not FALLBACK_SNS:
        print("⚠️ FALLBACK_SNS 환경변수가 설정되어 있지 않음. 알림 누락 위험")
        return

    try:
        sns = boto3.client("sns")
        sns.publish(
            TopicArn=FALLBACK_SNS,
            Subject=subject,
            Message=message
        )
        print("🔁 SNS fallback 알림 전송 완료")
    except Exception as e:
        print(f"❌ SNS fallback 전송 실패: {e}")
