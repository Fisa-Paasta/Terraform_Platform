from services.ec2 import stop_tagged_ec2
from services.rds import stop_tagged_rds
from services.eks import delete_tagged_eks
from services.s3 import delete_tagged_s3
from services.cloudfront import delete_tagged_cloudfront
from services.waf import delete_tagged_waf
from services.route53 import delete_tagged_hosted_zones
from utils.slack import send_slack

def lambda_handler(event, context):
    try:
        all_stopped = {
            "EC2": stop_tagged_ec2(),
            "RDS": stop_tagged_rds(),
            "EKS": delete_tagged_eks(),
            "S3" : delete_tagged_s3(),
            "CF" : delete_tagged_cloudfront(),
            "WAF" : delete_tagged_waf(),
            "R53" : delete_tagged_hosted_zones()
        }

        messages = []
        for svc, ids in all_stopped.items():
            if ids:
                messages.append(f"❌ [{svc}] 삭제됨:\n" + "\n".join(f"- {i}" for i in ids))

        if not messages:
            messages.append("✅ 삭제 대상 리소스가 없습니다.")
        
        send_slack("\n".join(messages))
        return all_stopped

    except Exception as e:
        send_slack(f"❌ 리소스 삭제 중 오류 발생:\n```\n{str(e)}\n```")
        raise
