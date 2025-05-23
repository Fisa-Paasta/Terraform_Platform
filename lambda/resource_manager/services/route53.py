import boto3
import os

r53 = boto3.client("route53")
TAG_KEY = os.environ.get("TAG_KEY", "AutoStop")
TAG_VALUE = os.environ.get("TAG_VALUE", "true")

def delete_tagged_hosted_zones():
    deleted = []
    zones = r53.list_hosted_zones()["HostedZones"]

    for z in zones:
        zone_id = z["Id"].split("/")[-1]
        try:
            tags = r53.list_tags_for_resource(ResourceType="hostedzone", ResourceId=zone_id)["ResourceTagSet"]["Tags"]
            tag_dict = {tag["Key"]: tag["Value"] for tag in tags}
            if tag_dict.get(TAG_KEY) == TAG_VALUE:
                _delete_all_records(zone_id)
                r53.delete_hosted_zone(Id=zone_id)
                deleted.append(z["Name"])
        except Exception as e:
            print(f"[Route53] ❌ {z['Name']} skip: {e}")
    return deleted

def _delete_all_records(zone_id):
    records = r53.list_resource_record_sets(HostedZoneId=zone_id)["ResourceRecordSets"]
    changes = []
    for r in records:
        if r["Type"] not in ["NS", "SOA"]:  # 기본 레코드는 유지
            changes.append({
                "Action": "DELETE",
                "ResourceRecordSet": r
            })
    if changes:
        r53.change_resource_record_sets(
            HostedZoneId=zone_id,
            ChangeBatch={"Changes": changes}
        )
