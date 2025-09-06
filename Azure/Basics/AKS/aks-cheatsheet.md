## Nodepools

1. List nodepools
`az aks nodepool list --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME -o table `

2. Disable cluster autoscaler
`az aks nodepool update --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME --name <nodepool-name> --disable-cluster-autoscaler`

3. Enable auto provisioning
`az aks update --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME --node-provisioning-mode Auto`

4. 
