### IRSA
- IAM Roles for Service Accounts (IRSA) provide the ability to manage credentials for your applications.
- You associate an IAM role with a Kubernetes Service Account and configure your Pods to use that Service Account.

Steps:
- create IAM OIDC Identity Provider
- Check the OIDC provider `aws iam list-open-id-connect-providers`
- check the association with the cluster `aws eks describe-cluster --name ${EKS_CLUSTER_NAME} --query 'cluster.identity'`
- Create an IAM role which provides access to the required resource like s3,dynamodb or whatever.
- The trust relationship of the iam role should be OIDC ,example

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "OIDC_ARN"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.us-west-2.amazonaws.com/id/22E1209C76AE64F8F612F8E703E5BBD7:sub": "system:serviceaccount:carts:carts"
        }
      }
    }
  ]
}
```
- Once it's done , make sure the service account associated with the pod/deployment has required annotation.
```
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: ${CARTS_IAM_ROLE}
  name: carts
  namespace: carts

```
- Restart the pod/deployment `kubectl rollout restart -n carts deployment/carts`

### EKS Pod Identity
- Allow kubernetes resources like pods to access aws resources.
Steps:
- Add EKS add-on for this
```
aws eks create-addon --cluster-name $EKS_CLUSTER_NAME --addon-name eks-pod-identity-agent
```
- Running the above command will create daemonsets in our cluster `kubectl -n kube-system get daemonset eks-pod-identity-agent`
- Create an IAM role with necessary permissions to access aws resources
- The role must have the following trust relationship
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "pods.eks.amazonaws.com"
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
}
```
- Create eks pod identity using the following command

```
aws eks create-pod-identity-association --cluster-name ${EKS_CLUSTER_NAME} \
  --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EKS_CLUSTER_NAME}-carts-dynamo \
  --namespace carts --service-account carts

```
- Associate the pod identity with the IAM role

```
aws eks create-pod-identity-association --cluster-name ${EKS_CLUSTER_NAME} \
  --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EKS_CLUSTER_NAME}-carts-dynamo \
  --namespace carts --service-account carts

```
