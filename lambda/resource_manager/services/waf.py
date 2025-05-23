import boto3
import os

waf = boto3.client("wafv2")
TAG_KEY = os.environ.get("TAG_KEY", "AutoStop")
TAG_VALUE = os.environ.get("TAG_VALUE", "true")
SCOPE = "REGIONAL"  # CLOUDFRONT or REGIONAL

def delete_tagged_waf():
    deleted = []
    # WebACL
    acls = waf.list_web_acls(Scope=SCOPE)["WebACLs"]
    for acl in acls:
        arn = acl["ARN"]
        tags = waf.list_tags_for_resource(ResourceARN=arn)["TagInfoForResource"]["TagList"]
        tag_dict = {t["Key"]: t["Value"] for t in tags}
        if tag_dict.get(TAG_KEY) == TAG_VALUE:
            waf.delete_web_acl(Name=acl["Name"], Scope=SCOPE, Id=acl["Id"], LockToken=acl["LockToken"])
            deleted.append(f"WebACL: {acl['Name']}")

    # RuleGroups
    rgs = waf.list_rule_groups(Scope=SCOPE)["RuleGroups"]
    for rg in rgs:
        arn = rg["ARN"]
        tags = waf.list_tags_for_resource(ResourceARN=arn)["TagInfoForResource"]["TagList"]
        tag_dict = {t["Key"]: t["Value"] for t in tags}
        if tag_dict.get(TAG_KEY) == TAG_VALUE:
            waf.delete_rule_group(Name=rg["Name"], Scope=SCOPE, Id=rg["Id"], LockToken=rg["LockToken"])
            deleted.append(f"RuleGroup: {rg['Name']}")

    return deleted
