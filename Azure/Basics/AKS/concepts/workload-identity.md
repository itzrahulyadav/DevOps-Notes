# Hands-On Lab: Kubernetes Workload Identity in AKS

This lab demonstrates how to configure a pod in Azure Kubernetes Service (AKS) to securely access Azure resources using a passwordless identity. It uses the modern Workload Identity feature, which relies on OIDC federation.

**Goal:** Deploy a simple pod that can authenticate to Azure and list subscriptions without using any secrets, client secrets, or passwords.

### Prerequisites

1.  An AKS cluster with the OIDC Issuer and Workload Identity features enabled.
    ```bash
    # Example cluster create command
    az aks create \
      --resource-group my-aks-rg \
      --name my-aks-cluster \
      # ... other flags ...
      --enable-oidc-issuer \
      --enable-workload-identity
    ```
2.  `kubectl` configured to connect to your AKS cluster.
3.  Azure CLI installed and logged in to your account.

---

### Step 1: Create the Azure Identity (Managed Identity)

First, we create the User-Assigned Managed Identity in Azure. This will be the identity that our pod assumes when it talks to Azure.

```bash
# Set variables for your environment
RESOURCE_GROUP="my-aks-rg"
LOCATION="eastus" # IMPORTANT: Use your cluster's region
IDENTITY_NAME="MyPod-ManagedIdentity"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# 1. Create the User-Assigned Managed Identity
az identity create \
  --name $IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# 2. Get the Principal ID of the new Managed Identity for role assignment
IDENTITY_PRINCIPAL_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP --query "principalId" -o tsv)

# 3. Grant the identity permission to read subscriptions
# This follows the principle of least privilege for our test.
az role assignment create \
  --role "Reader" \
  --assignee-object-id $IDENTITY_PRINCIPAL_ID \
  --assignee-principal-type ServicePrincipal \
  --scope "/subscriptions/$SUBSCRIPTION_ID"


# 1. Create a dedicated namespace for our test application
kubectl create namespace workload-identity-test

# 2. Create the Service Account within that namespace

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
  namespace: workload-identity-test
EOF

```

# Set a variable for your AKS cluster name
AKS_CLUSTER_NAME="my-aks-cluster"

# 1. Get the OIDC Issuer URL of your AKS cluster
`AKS_OIDC_ISSUER=$(az aks show --name $AKS_CLUSTER_NAME --resource-group $RESOURCE_GROUP --query "oidcIssuerProfile.issuerUrl" -o tsv)`

# 2. Get the Client ID of our Managed Identity

`IDENTITY_CLIENT_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP --query "clientId" -o tsv)`

# 3. Create the Federated Credential link
```
az identity federated-credential create \
  --name "my-pod-federation" \
  --identity-name $IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP \
  --issuer $AKS_OIDC_ISSUER \
  --subject "system:serviceaccount:workload-identity-test:my-app-sa" \
  --audience "api://AzureADTokenExchange"

```
```
#4 . create the pod


cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: workload-identity-pod
  namespace: workload-identity-test
  labels:
    azure.workload.identity/use: "true" # Required label for the webhook
spec:
  # Link the pod to our Kubernetes Service Account
  serviceAccountName: my-app-sa
  containers:
    - image: mcr.microsoft.com/azure-cli
      name: oidc
      # Keep the pod running indefinitely for us to test
      command: ["/bin/bash", "-c", "sleep infinity"]
EOF

```

5.
# 1. Get a shell inside the pod
kubectl exec -it workload-identity-pod --namespace workload-identity-test -- /bin/bash

# --- You are now inside the pod's shell ---

# 2. Log in using the federated token. No secrets are passed.
# The webhook has already mounted the token and set the environment variables.
```
az login \
  --service-principal \
  -u $AZURE_CLIENT_ID \
  -t $AZURE_TENANT_ID \
  --federated-token "$(cat /var/run/secrets/azure/tokens/azure-identity-token)"

```


# 3. Run a command to test access.
# If login was successful, this will list your Azure subscriptions.
az account list --output table

# 4. Exit the pod's shell
exit
