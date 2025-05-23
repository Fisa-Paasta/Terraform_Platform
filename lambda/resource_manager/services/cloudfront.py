import boto3
import os
import time

cf = boto3.client("cloudfront")
TAG_KEY = os.environ.get("TAG_KEY", "AutoStop")
TAG_VALUE = os.environ.get("TAG_VALUE", "true")

def delete_tagged_cloudfront():
    deleted = []
    dists = cf.list_distributions()
    items = dists.get("DistributionList", {}).get("Items", [])

    for dist in items:
        dist_id = dist["Id"]
        try:
            tags = cf.list_tags_for_resource(Resource=dist["ARN"])["Tags"]["Items"]
            tag_dict = {tag["Key"]: tag["Value"] for tag in tags}

            if tag_dict.get(TAG_KEY) == TAG_VALUE:
                # 비활성화 필요
                if dist["Enabled"]:
                    _disable_distribution(dist_id)

                # 비활성화 후 기다렸다가 삭제
                _wait_until_deployed(dist_id)
                cf.delete_distribution(Id=dist_id, IfMatch=_get_etag(dist_id))
                deleted.append(dist_id)

        except Exception as e:
            print(f"[CloudFront] ❌ {dist_id} skip: {e}")
    return deleted

def _disable_distribution(dist_id):
    dist_config = cf.get_distribution_config(Id=dist_id)
    config = dist_config["DistributionConfig"]
    config["Enabled"] = False  # disable first
    etag = dist_config["ETag"]

    cf.update_distribution(Id=dist_id, DistributionConfig=config, IfMatch=etag)
    print(f"[CloudFront] 🔕 Disabled {dist_id}")

def _get_etag(dist_id):
    return cf.get_distribution_config(Id=dist_id)["ETag"]

def _wait_until_deployed(dist_id):
    print(f"[CloudFront] ⏳ Waiting for {dist_id} to become 'Deployed'")
    while True:
        status = cf.get_distribution(Id=dist_id)["Distribution"]["Status"]
        if status == "Deployed":
            print(f"[CloudFront] ✅ {dist_id} is deployed.")
            break
        time.sleep(5)
