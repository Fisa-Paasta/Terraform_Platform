import boto3
import os

eks = boto3.client("eks")
TAG_KEY = os.environ.get("TAG_KEY", "AutoStop")
TAG_VALUE = os.environ.get("TAG_VALUE", "true")

def delete_tagged_eks():
    deleted = []

    # 🔍 1. 클러스터 전체 조회
    cluster_names = eks.list_clusters()["clusters"]
    for cluster in cluster_names:
        desc = eks.describe_cluster(name=cluster)["cluster"]
        tags = desc.get("tags", {})
        
        if tags.get(TAG_KEY) == TAG_VALUE:
            # ✅ 2. 클러스터 안의 노드그룹 삭제
            ngs = eks.list_nodegroups(clusterName=cluster)["nodegroups"]
            for ng in ngs:
                eks.delete_nodegroup(clusterName=cluster, nodegroupName=ng)
                deleted.append(f"{cluster}/nodegroup:{ng}")
            
            # ✅ 3. 클러스터 삭제 (노드그룹 삭제 요청 이후 바로)
            eks.delete_cluster(name=cluster)
            deleted.append(f"{cluster}/cluster")

    return deleted
