import boto3
import os

s3 = boto3.client("s3")
TAG_KEY = os.environ.get("TAG_KEY", "AutoStop")
TAG_VALUE = os.environ.get("TAG_VALUE", "true")

def delete_tagged_s3():
    deleted = []
    buckets = s3.list_buckets()["Buckets"]
    for b in buckets:
        name = b["Name"]
        try:
            tags = s3.get_bucket_tagging(Bucket=name)["TagSet"]
            tag_dict = {tag["Key"]: tag["Value"] for tag in tags}
            if tag_dict.get(TAG_KEY) == TAG_VALUE:
                # delete all objects (required before bucket deletion)
                _clear_bucket(name)
                s3.delete_bucket(Bucket=name)
                deleted.append(name)
        except Exception as e:
            print(f"[S3] ❌ {name} skip: {e}")
    return deleted

def _clear_bucket(bucket_name):
    try:
        objs = s3.list_objects_v2(Bucket=bucket_name)
        if "Contents" in objs:
            keys = [{"Key": obj["Key"]} for obj in objs["Contents"]]
            s3.delete_objects(Bucket=bucket_name, Delete={"Objects": keys})
    except Exception as e:
        print(f"[S3] 삭제 실패: {e}")
