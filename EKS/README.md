## EKS - Elastic Kubernetes Service

### Managed Node Groups

-  Managed node groups are Amazon Elastic Compute Cloud (EC2) instances that run as worker nodes in your EKS cluster.
-  A node group is one or more EC2 instances that are deployed in an EC2 Auto Scaling group.

you can use the following command to check the node groups(eksctl must be installed)

```
eksctl get nodegroup --cluster $EKS_CLUSTER_NAME --name $EKS_DEFAULT_MNG_NAME
```
- Nodes are distributed over multiple subnets in various availability zones, providing high availability
- 
