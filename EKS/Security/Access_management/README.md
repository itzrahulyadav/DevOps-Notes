### Cluster management access API 
- AWS works at cluster management access api.It simplifies identity mapping between AWS IAM and Kubernetes RBAC, eliminating the need to
  switch between AWS and Kubernetes APIs for access management and reducing operational overhead. The tool also enables
  cluster administrators to revoke or refine cluster-admin permissions automatically granted to the AWS IAM principal
  used to create the cluster.

- Cluster access management API works on two concepts:
  - Access Entries (Authentication)
  - Access Policies (Authorization).Amazon EKS access policies include Kubernetes permissions, not IAM permissions

- you can check the access policies available using the following command `aws eks list-access-policies`
- Check the cluster access entries `aws eks list-access-entries --cluster $EKS_CLUSTER_NAME`

## Example of creating access entry in eks
- Create an IAM role, let's say test-iam-role
- Create an iam access entry for the role
```
aws eks create-access-entry --cluster-name $EKS_CLUSTER_NAME \
  --principal-arn $READ_ONLY_IAM_ROLE

```
- Associate an access policy with the access entry created in the previous step:
```
aws eks associate-access-policy --cluster-name $EKS_CLUSTER_NAME \
  --principal-arn $READ_ONLY_IAM_ROLE \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy \
  --access-scope type=cluster

```

- Update the kube-config
```
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME \
  --role-arn $READ_ONLY_IAM_ROLE --alias readonly --user-alias readonly

```
- Check the access `kubectl --context readonly auth whoami`
- Try to access resources `kubectl --context readonly get pod -A`
- Scope the policy to namespace only
```
aws eks associate-access-policy --cluster-name $EKS_CLUSTER_NAME \
  --principal-arn $READ_ONLY_IAM_ROLE \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy \
  --access-scope type=namespace,namespaces=carts

```
- Now the role will only be able to list resources in the carts namespace
- Additional access policies can also be added
```
aws eks associate-access-policy --cluster-name $EKS_CLUSTER_NAME \
  --principal-arn $READ_ONLY_IAM_ROLE \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy \
  --access-scope type=namespace,namespaces=assets

```

### Kubernetes RBAC
- Access entries can be combined with kubernetes RBAC
- Let's create a role in kubernetes and associate it with our IAM role that we created earlier.
```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: carts
  name: carts-team-role
rules:
  - apiGroups: [""]
    resources: ["*"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["delete"]

```
- Create a rolebinding that will map the role with the kubernetes group named devs
```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: carts-team-role-binding
  namespace: carts
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: carts-team-role
subjects:
  - kind: Group
    name: devs
    apiGroup: rbac.authorization.k8s.io
```

- Create an access entry that will map kubernetes rbac with iam role
  
```
aws eks create-access-entry --cluster-name $EKS_CLUSTER_NAME \
  --principal-arn <iam_role_ARN> \
  --kubernetes-groups devs
```
