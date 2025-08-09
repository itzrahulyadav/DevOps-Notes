### Create an AKS Cluster from the very scratch

1. Create a vnet with one subnet

```
az network vnet create \
  --resource-group my-aks-rg \
  --name my-aks-vnet \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name aks-subnet \
  --subnet-prefix 10.0.1.0/24


```

2. Create an additional subnet

```

az network vnet subnet create \
  --resource-group my-aks-rg \
  --vnet-name my-aks-vnet \
  --name another-subnet \
  --address-prefix 10.0.2.0/24

```

3. Get the subnet ID

```
VNET_SUBNET_ID=$(az network vnet subnet show --resource-group my-aks-rg --vnet-name my-aks-vnet --name aks-subnet --query id -o tsv)
```

4. create aks cluster
   
```
az aks create \
  --resource-group my-aks-rg \
  --name my-aks-cluster \
  --node-count 2 \
  --network-plugin azure \
  --vnet-subnet-id $VNET_SUBNET_ID \
  --enable-managed-identity \
  --generate-ssh-keys

```

5. Connect to the cluster

`az aks get-credentials --resource-group my-aks-rg --name my-aks-cluster`


6. 
