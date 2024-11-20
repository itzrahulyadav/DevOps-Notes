### Managed Node Group
- We can check the node group using the following command
```
 eksctl get nodegroup --cluster $EKS_CLUSTER_NAME --name $EKS_DEFAULT_MNG_NAME
```
- Check the azs `kubectl get nodes -o wide --label-columns topology.kubernetes.io/zone`
- Change the node config using the following command
  ```
aws eks update-nodegroup-config --cluster-name $EKS_CLUSTER_NAME \
  --nodegroup-name $EKS_DEFAULT_MNG_NAME --scaling-config minSize=4,maxSize=6,desiredSize=4
```
