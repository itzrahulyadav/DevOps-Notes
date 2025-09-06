## Karpenter


[Official docs](https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/)

Before setting up Karpenter, let’s cover key terms you’ll encounter:


###  NodePool:

A Kubernetes Custom Resource Definition (CRD) that defines the constraints for node provisioning, such as instance types, architectures, operating systems, and capacity types (e.g., On-Demand or Spot). It specifies how Karpenter selects nodes for pods.
Example: A NodePool might allow c5.large or m5.xlarge instances in us-west-2a with Spot priority.

### EC2NodeClass:
Another CRD that defines AWS-specific configurations for nodes, such as the IAM role, AMI (Amazon Machine Image), subnets, and security groups.
Example: Links to an IAM role (KarpenterNodeRole) and specifies an Amazon Linux 2023 AMI.
Provisioner (Deprecated in v1+):
In older Karpenter versions (v0.x), a Provisioner was used instead of NodePool and EC2NodeClass. It combined node selection and cloud provider settings. In Karpenter v1+, NodePool and EC2NodeClass replace it for better modularity.
### NodeClaim:
A CRD representing a request for a new node. When Karpenter detects unschedulable pods, it creates a NodeClaim to provision a matching EC2 instance, which becomes a Kubernetes node.
Consolidation:
Karpenter’s process of moving pods to fewer nodes to optimize resource usage, terminating underutilized nodes. It uses a bin-packing algorithm to pack pods efficiently.

### Disruption:
The process of terminating nodes when they’re no longer needed or to consolidate workloads. Controlled by policies like consolidationPolicy: WhenEmptyOrUnderutilized and consolidateAfter.

###  Capacity Type:
Specifies whether nodes use On-Demand or Spot instances. Spot Instances are cheaper but can be interrupted, while On-Demand ensures stability. Karpenter prioritizes cost-effective options.

### Node Affinity:
Kubernetes scheduling constraints (e.g., nodeSelector, taints, tolerations) that Karpenter respects when provisioning nodes to match pod requirements.

### Karpenter Controller:
The Kubernetes deployment that runs Karpenter, monitoring unschedulable pods and managing node lifecycle via AWS EC2 APIs.

### Spot Instances:
AWS EC2 instances offered at a discount but subject to interruption. Karpenter’s support for Spot Instances enhances cost savings.
TTL (Time to Live):
Settings like expireAfter (e.g., 720h for 30 days) or ttlSecondsAfterEmpty (e.g., 30s) control when nodes are terminated due to age or underutilization.

###  Bin-Packing:
Karpenter’s algorithm to efficiently pack pods onto nodes, minimizing resource waste and reducing the number of nodes needed.




### Installation

1. Set env variables

```
export CLUSTER_NAME="eks-cluster"
export AWS_REGION="ap-south-1"
export KARPENTER_NAMESPACE="kube-system"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export KARPENTER_VERSION="1.0.0"
export OIDC_ENDPOINT=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text)

```

2. Create karpenterNodeRole

This role is used by EC2 instances launched by Karpenter.

```
cat <<EOF > node-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
aws iam create-role --role-name KarpenterNodeRole-$CLUSTER_NAME --assume-role-policy-document file://node-trust-policy.json


```

3. Add the following permissions

```
aws iam attach-role-policy --role-name KarpenterNodeRole-$CLUSTER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-role-policy --role-name KarpenterNodeRole-$CLUSTER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam attach-role-policy --role-name KarpenterNodeRole-$CLUSTER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam attach-role-policy --role-name KarpenterNodeRole-$CLUSTER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

```

4. Create instance profile

```
aws iam create-instance-profile --instance-profile-name KarpenterNodeInstanceProfile-$CLUSTER_NAME
aws iam add-role-to-instance-profile --instance-profile-name KarpenterNodeInstanceProfile-$CLUSTER_NAME --role-name KarpenterNodeRole-$CLUSTER_NAME

```


5. Create KarpenterControllerRole:

This role is used by the Karpenter controller via IRSA.
Create IRSA

```
cat <<EOF > controller-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$AWS_ACCOUNT_ID:oidc-provider/${OIDC_ENDPOINT#*//}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${OIDC_ENDPOINT#*//}:aud": "sts.amazonaws.com",
          "${OIDC_ENDPOINT#*//}:sub": "system:serviceaccount:$KARPENTER_NAMESPACE:karpenter"
        }
      }
    }
  ]
}
EOF
aws iam create-role --role-name KarpenterControllerRole-$CLUSTER_NAME --assume-role-policy-document file://controller-trust-policy.json

```



6. Create controller policy

```
cat <<EOF > controller-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ec2:DescribeImages",
        "ec2:RunInstances",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DeleteLaunchTemplate",
        "ec2:CreateTags",
        "ec2:CreateLaunchTemplate",
        "ec2:CreateFleet",
        "ec2:*"
        "ec2:DescribeSpotPriceHistory",
        "pricing:GetProducts"
        "iam:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:TerminateInstances",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/karpenter.sh/nodepool": "*"
        }
      },
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::$AWS_ACCOUNT_ID:role/KarpenterNodeRole-$CLUSTER_NAME"
    },
    {
      "Effect": "Allow",
      "Action": "eks:DescribeCluster",
      "Resource": "arn:aws:eks:$AWS_REGION:$AWS_ACCOUNT_ID:cluster/$CLUSTER_NAME"
    }
  ]
}
EOF
aws iam put-role-policy --role-name KarpenterControllerRole-$CLUSTER_NAME --policy-name KarpenterControllerPolicy --policy-document file://controller-policy.json

```

7. install karpenter

```
export KARPENTER_VERSION="1.0.8"
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --namespace $KARPENTER_NAMESPACE \
  --version $KARPENTER_VERSION \
  --set settings.clusterName=$CLUSTER_NAME \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::$AWS_ACCOUNT_ID:role/KarpenterControllerRole-$CLUSTER_NAME \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi \
  --set controller.resources.limits.cpu=1 \
  --set controller.resources.limits.memory=1Gi \
  --create-namespace

```

8. configure NodePool and EC2NodeClass


```
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: default
spec:
  template:
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c", "m", "r"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default
  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 30s
---
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default
spec:
  amiFamily: AL2023
  role: KarpenterNodeRole-eks-cluster
  amiSelectorTerms:
    - id: ami-09f1941e8730d7702
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: eks-cluster
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: eks-cluster

```

9. Tags security groups and subnets;

```
aws ec2 create-tags --resources <subnet-id-1> <subnet-id-2> --tags Key=karpenter.sh/discovery,Value=$CLUSTER_NAME
aws ec2 create-tags --resources <security-group-id> --tags Key=karpenter.sh/discovery,Value=$CLUSTER_NAME

```


10. find optimized amis

```
aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.31/amazon-linux-2023/x86_64/standard/recommended/image_id --region ap-south-1 --query Parameter.Value --output text

```

11. Troubleshooting

```
kubectl logs -n kube-system -l app.kubernetes.io/name=karpenter | grep -i error
kubectl get nodepools -w
kubectl get pods -n default -w
kubectl get nodes -w
kubectl get nodeclaims -n kube-system -w
kubectl logs -n kube-system -l app.kubernetes.io/name=karpenter -f

kubectl get clusterrole karpenter -o yaml

kubectl get nodepools
kubectl describe nodepool default
kubectl describe ec2nodeclass default

kubectl describe pod -n kube-system -l app.kubernetes.io/name=karpenter

```


12. Allow instance profile to authenticate to the cluster

```

aws eks create-access-entry \
  --cluster-name eks-cluster \
  --principal-arn arn:aws:iam::<account-id>:role/KarpenterNodeRole-eks-cluster \
  --type STANDARD \
  --region ap-south-1
aws eks associate-access-policy \
  --cluster-name eks-cluster \
  --principal-arn arn:aws:iam::<account-id>:role/KarpenterNodeRole-eks-cluster \
  --access-scope type=cluster \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSNodeAccess \
  --region ap-south-1

```
