import boto3
import os

ec2 = boto3.client("ec2")
TAG_KEY = os.environ.get("TAG_KEY", "AutoStop")
TAG_VALUE = os.environ.get("TAG_VALUE", "true")

def stop_tagged_ec2():
    filters = [{
        'Name': f"tag:{TAG_KEY}",
        'Values': [TAG_VALUE]
    }]

    instances_to_terminate = []
    reservations = ec2.describe_instances(Filters=filters)["Reservations"]
    for res in reservations:
        for inst in res["Instances"]:
            if inst["State"]["Name"] == "running":
                instances_to_terminate.append(inst["InstanceId"])

    if instances_to_terminate:
        ec2.terminate_instances(InstanceIds=instances_to_terminate)

    return instances_to_terminate
