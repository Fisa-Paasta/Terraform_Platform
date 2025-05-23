import boto3
import os

rds = boto3.client("rds")
TAG_KEY = os.environ.get("TAG_KEY", "AutoStop")
TAG_VALUE = os.environ.get("TAG_VALUE", "true")

def delete_tagged_rds():
    deleted = []
    dbs = rds.describe_db_instances()["DBInstances"]
    for db in dbs:
        db_id = db["DBInstanceIdentifier"]
        tags = rds.list_tags_for_resource(ResourceName=db["DBInstanceArn"])["TagList"]
        tag_dict = {tag["Key"]: tag["Value"] for tag in tags}

        if tag_dict.get(TAG_KEY) == TAG_VALUE and db["DBInstanceStatus"] == "available":
            rds.delete_db_instance(
                DBInstanceIdentifier=db_id,
                SkipFinalSnapshot=True  # ⚠️ 필요 시 False + Snapshot 설정 가능
            )
            deleted.append(db_id)

    return deleted
