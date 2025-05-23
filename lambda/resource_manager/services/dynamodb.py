import boto3
import os

ddb = boto3.client("dynamodb")
TAG_KEY = os.environ.get("TAG_KEY", "AutoStop")
TAG_VALUE = os.environ.get("TAG_VALUE", "true")

def delete_tagged_dynamodb():
    deleted = []
    tables = ddb.list_tables()["TableNames"]
    for name in tables:
        tags = ddb.list_tags_of_resource(
            ResourceArn=_get_table_arn(name)
        )["Tags"]
        tag_dict = {tag["Key"]: tag["Value"] for tag in tags}
        if tag_dict.get(TAG_KEY) == TAG_VALUE:
            ddb.delete_table(TableName=name)
            deleted.append(name)
    return deleted

def _get_table_arn(table_name):
    region = os.environ.get("AWS_REGION", "ap-northeast-2")
    account_id = boto3.client("sts").get_caller_identity()["Account"]
    return f"arn:aws:dynamodb:{region}:{account_id}:table/{table_name}"
