## EKS - Elastic Kubernetes Service

### Create a new EKS cluster

1. Create a vpc with with the following cidr ` 10.0.0.0/16`
2. Create 2 private subnet `10.0.32.0/19` and `10.0.64.0/19`
3. Create 2 public subnet `10.0.64.0/19` and `10.0.96.0/19`
4. Create internet gateway,nat gateways and modify the route table for public and private subnets to allow access to the internet.
5. Create iam role for eks cluster named eks_policy and attach the following policy `arn:aws:iam::aws:policy/AmazonEKSClusterPolicy`
6. Create eks cluster with auth mode = API ,public endpoint access=true and private = false for now. It can be modified depending on the requirements.
7. Create an IAM role for worker nodes with trust type=ec2 and attach the following policies ` arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy && arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy && arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly`
8. Install helm and use the charts to install load balancer controller,metrics server.

### Managed Node Groups

-  Managed node groups are Amazon Elastic Compute Cloud (EC2) instances that run as worker nodes in your EKS cluster.
-  A node group is one or more EC2 instances that are deployed in an EC2 Auto Scaling group.

you can use the following command to check the node groups(eksctl must be installed)

```
eksctl get nodegroup --cluster $EKS_CLUSTER_NAME --name $EKS_DEFAULT_MNG_NAME
```
- Nodes are distributed over multiple subnets in various availability zones, providing high availability
- 
