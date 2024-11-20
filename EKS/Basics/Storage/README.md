### EBS CSI driver
- Create a role for EBS csi driver
- Follow the command below or you can use other ways mentioned [here](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
```
eksctl create iamserviceaccount \
        --name ebs-csi-controller-sa \
        --namespace kube-system \
        --cluster my-cluster \
        --role-name AmazonEKS_EBS_CSI_DriverRole \
        --role-only \
        --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
        --approve

```
- Add EBS CSI driver add-on in our cluster
  
```
aws eks create-addon --cluster-name $EKS_CLUSTER_NAME --addon-name aws-ebs-csi-driver \
  --service-account-role-arn $EBS_CSI_ADDON_ROLE \
  --configuration-values '{"defaultStorageClass":{"enabled":true}}'

```

- Run the following command to check the installation `kubectl get daemonset ebs-csi-node -n kube-system`

### EFS CSI Driver
- If you want to follow you can refer to [example](https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/README.md#examples) app.
- Create an IAM role for EFS driver

```
export cluster_name=my-cluster
export role_name=AmazonEKS_EFS_CSI_DriverRole
eksctl create iamserviceaccount \
    --name efs-csi-controller-sa \
    --namespace kube-system \
    --cluster $cluster_name \
    --role-name $role_name \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
    --approve

TRUST_POLICY=$(aws iam get-role --role-name $role_name --query 'Role.AssumeRolePolicyDocument' | \
    sed -e 's/efs-csi-controller-sa/efs-csi-*/' -e 's/StringEquals/StringLike/')
aws iam update-assume-role-policy --role-name $role_name --policy-document "$TRUST_POLICY"


```

- Configure the EBS add-on
```
aws eks create-addon --cluster-name $EKS_CLUSTER_NAME --addon-name aws-efs-csi-driver \
  --service-account-role-arn $EFS_CSI_ADDON_ROLE

```
- Check the installation using `kubectl get daemonset efs-csi-node -n kube-system`
- Get the efs_id using the following command `export EFS_ID=$(aws efs describe-file-systems --query "FileSystems[?Name=='$EKS_CLUSTER_NAME-efs-assets'] | [0].FileSystemId" --output text)`
- Create a storage class using the manifest file
```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: ${EFS_ID}
  directoryPerms: "700"

```
- Create pvc to dynamically provision volumes
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-claim
  namespace: assets
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi


```
- Create deployment and use volume section in the spec file
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: assets
spec:
  replicas: 2
  template:
    spec:
      initContainers:
        - name: copy
          image: "public.ecr.aws/aws-containers/retail-store-sample-assets:0.4.0"
          command:
            ["/bin/sh", "-c", "cp -R /usr/share/nginx/html/assets/* /efsvolume"]
          volumeMounts:
            - name: efsvolume
              mountPath: /efsvolume
      containers:
        - name: assets
          volumeMounts:
            - name: efsvolume
              mountPath: /usr/share/nginx/html/assets
      volumes:
        - name: efsvolume
          persistentVolumeClaim:
            claimName: efs-claim
```
- Check the mounting option in the deployment
```
kubectl get deployment -n assets \
  -o yaml | yq '.items[].spec.template.spec.containers[].volumeMounts'
```
- To verify the changes , let's create file in one pod and check if it's their in the second pod
```
kubectl exec --stdin $POD_NAME \
  -n assets -c assets -- bash -c 'touch /usr/share/nginx/html/assets/newproduct.png'

```
- Check the other pod `kubectl exec --stdin $POD_NAME -n assets -c assets -- bash -c 'ls /usr/share/nginx/html/assets'`
