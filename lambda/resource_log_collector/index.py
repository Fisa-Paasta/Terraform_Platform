from utils.slack import send_slack
from datetime import datetime

def lambda_handler(event, context):
    try:
        log_data = event.get("awslogs", {}).get("data", "")
        # decode + parse logic 생략...

        if "ERROR" in log_data:
            message = f"🚨 *에러 로그 감지됨!*\n```\n{log_data[:1000]}\n```"
        else:
            message = "✅ 로그 수집 완료 (오류 없음)"

        send_slack(message, title="🪵 로그 수집 알림")
    except Exception as e:
        send_slack(f"❌ 로그 수집 중 오류 발생:\n```\n{str(e)}\n```", title="🚨 로그 수집 오류")

