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


### Pod security standard
- Pod Security Standards (PSS) are a set of predefined security policies in Kubernetes that enforce best practices for securing pods at various levels of privilege and isolation
- It defines three policies
   - Privileged
   - Baseline
   - Restricted
- Useful links [1](https://kubernetes.io/docs/concepts/security/pod-security-standards/),[2](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/),[3](https://kubernetes.io/docs/tasks/configure-pod-container/enforce-standards-admission-controller/#configure-the-admission-controller)
-  We need to set specific PSS profiles and PSA modes at the Kubernetes Namespace level, to opt Namespaces into Pod security provided by the PSA and PSS.
- Example:
```
apiVersion: v1
kind: Namespace
metadata:
  name: psa-pss-test-ns
  labels:
    # pod-security.kubernetes.io/enforce: privileged
    # pod-security.kubernetes.io/audit: privileged
    # pod-security.kubernetes.io/warn: privileged

    # pod-security.kubernetes.io/enforce: baseline
    # pod-security.kubernetes.io/audit: baseline
    # pod-security.kubernetes.io/warn: baseline

    # pod-security.kubernetes.io/enforce: restricted
    # pod-security.kubernetes.io/audit: restricted
    # pod-security.kubernetes.io/warn: restricted

```
- The PSS can be implemented using admission controllers like:

   Pod Security Admission (native in Kubernetes 1.23+)
   Policy enforcement tools like:
   - Kyverno
   - OPA (Open Policy Agent) / Gatekeeper


### Kyverno

- It's a policy engine for kubernetes that integrates with kube-api server as a Dynamic Admission Controller, allowing policies to mutate and validate inbound Kubernetes API requests
- Kyverno uses declarative Kubernetes resources written in YAML, eliminating the need to learn a new policy language. Results are available as Kubernetes resources and events.
- Install and configure kyverno
```
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno --namespace kyverno kyverno/kyverno --create-namespace

```
- Create a sample policy
```
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: Enforce
  rules:
    - name: check-team
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: "Label 'CostCenter' is required to deploy the Pod"
        pattern:
          metadata:
            labels:
              CostCenter: "?*"

```
- The above policy will check if the requested pod has the label costcenter,if not request will be rejected.
- Kyverno can also be used for mutating rules
```
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-labels
spec:
  rules:
    - name: add-labels
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              CostCenter: IT


```

- The above mentioned rule automatically adds labels to the pod.
 ## Restricting image registries
 - Kyverno can be used to restrict pulling images from unknown repos
 - The following policy enforces pulling image only from the ecr.
```
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-image-registries
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: validate-registries
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: "Unknown Image registry."
        pattern:
          spec:
            containers:
              - image: "public.ecr.aws/*"
```
- Kyverno can also be used for auditing purpose.
- Kyverno saves all events and other audits in the same namespace where the event occured, it doesn't save historical information
- Kyverno has two types of validationFailureAction:
  - Audit mode: Allows resources to be created and reports the action in the Policy Reports.
  - Enforce mode: Denies resource creation but does not add an entry in the Policy Reports.
- For the action type audit kyverno will record the FAIL output in the policy report.
- Policy report can be seen using

```
kubectl get policyreports -A
```
