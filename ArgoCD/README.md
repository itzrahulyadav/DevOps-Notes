# Argocd

1. Installation

- for installation steps click [here](https://argo-cd.readthedocs.io/en/stable/getting_started/)

2. Accessing the Argocd server

```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

```

```
kubectl port-forward svc/argocd-server -n argocd 8080:443


```

3. Retrieve the username and password

```
argocd admin initial-password -n argocd
```

4. Login to the ArgoCD server

```
argocd login <ARGOCD_SERVER>

```


```markdown
# ArgoCD Application

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It helps teams manage and deploy applications across multiple Kubernetes clusters from a centralized location.

## Key Features

- Automated deployment of applications to specified target environments
- Support for multiple config management tools (Kustomize, Helm, etc)
- Web UI and CLI for application deployment and management  
- Automated sync between Git repositories and cluster states
- Role-Based Access Control (RBAC) integration
- SSO Integration
- Audit trails for application changes
- Health status monitoring of application resources
- Rollback capability to any application version
- Webhook integration for automated deployments

## Benefits

- Ensures consistency between Git and cluster states
- Simplifies multi-cluster deployments
- Provides clear visibility into application state
- Reduces deployment errors through automation
- Enables easy rollbacks of failed deployments
- Supports compliance through audit trails
```


# Method 1: Using YAML manifest
# Create a file named application.yaml:

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/itzrahulyadav/argocd-example-apps.git
    targetRevision: master
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: guestbook
  syncPolicy:
    syncOptions:
       - CreateNamespace=true
    automated:
      prune: true
      selfHeal: true

# Apply using:
# kubectl apply -f application.yaml

# Method 2: Using ArgoCD CLI
# Command format:
argocd app create myapp \
  --repo https://github.com/itzrahulyadav/argocd-example-apps.git \
  --revision master \
  --path guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace myapp \
  --sync-policy automated \
  --sync-option CreateNamespace=true \
  --auto-prune \
  --self-heal


```markdown
# ArgoCD Projects

ArgoCD Projects provide a logical grouping of applications and define constraints and configurations for those applications. They help in organizing and securing application deployments across teams and environments.

## Key Features of ArgoCD Projects

- **Resource Isolation**: Control which resources can be deployed
- **Source Repository Restrictions**: Limit which Git repositories can be used
- **Destination Restrictions**: Control which clusters/namespaces can be deployed to
- **Role-Based Access Control**: Define who can access and manage applications
- **Sync Windows**: Configure when applications can be synced

## Default Project

- Every ArgoCD installation comes with a default project
- Allows deployments from any source repository to any cluster
- Recommended to create custom projects for better security

## Project Configuration Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: my-project
  namespace: argocd
spec:
  description: Example project
  sourceRepos:
    - "https://github.com/my-org/*"
  destinations:
    - namespace: my-namespace
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: "*"
      kind: "Namespace"
  namespaceResourceWhitelist:
  - group: "*"
    kind: "*"
  namespaceResourceBlacklist:
    - group: ""
      kind: "ResourceQuota"

```
    

# ArgoCD Private Repository Access Configuration

# 1. Using HTTPS with Git credentials
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/my-org/my-private-repo.git
  username: git-user
  password: git-password


---
# 2. Using SSH with private key authentication
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-ssh
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@github.com:my-org/my-private-repo.git
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    <your-private-key-here>
    -----END OPENSSH PRIVATE KEY-----

---

The ssh key can be created using the following [steps](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)



# 3. Using HTTPS with token authentication
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-token
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/my-org/my-private-repo.git
  password: <github-personal-access-token>

---
# Example Application using private repository
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: private-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/my-org/my-private-repo.git
    targetRevision: main
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp
  syncPolicy:
    automated:
      prune: true
      selfHeal: true



# ArgoCD Sync Options Configuration

# Application-level sync options
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app
  namespace: argocd
spec:
  syncPolicy:
    syncOptions:
      # Create namespace if it doesn't exist
      - CreateNamespace=true
      
      # Automatically create/update network policies
      - ApplyOutOfSyncOnly=true
      
      # Prune resources that are no longer in Git
      - PrunePropagationPolicy=foreground
      
      # Validate resources can be applied before syncing
      - Validate=true
      
      # Respect resource hooks during sync
      - RespectIgnoreDifferences=true
      
      # Skip schema validation
      - ValidateSchema=false
      
      # Replace resources instead of applying changes
      - Replace=true
      
      # Retry failed sync attempts
      - Retry=true
      
    # Automated sync settings
    automated:
      # Automatically delete resources that are no longer in Git
      prune: true
      
      # Automatically sync when cluster state deviates from Git
      selfHeal: true
      
      # Allow sync to be triggered regardless of status
      allowEmpty: true

    # Sync retry options  
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m

    # Sync windows to control when syncs can occur
    syncWindows:
    - kind: allow
      schedule: '10 1 * * *'
      duration: 1h
      applications:
      - '*-prod'
      manualSync: true

```


# Example showing resource-level sync options using annotations

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-deployment
  annotations:
    argocd.argoproj.io/sync-options: Prune=false
    argocd.argoproj.io/compare-options: IgnoreExtraneous
spec:
  replicas: 3
  selector:
    matchLabels:
      app: example
  template:
    metadata:
      labels:
        app: example
    spec:
      containers:
      - name: nginx
        image: nginx:latest

---
apiVersion: v1
kind: Service
metadata:
  name: example-service
  annotations:
    # Skip resource during sync
    argocd.argoproj.io/sync-options: Skip
spec:
  selector:
    app: example
  ports:
  - port: 80
    targetPort: 80

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-config
  annotations:
    # Replace resource instead of applying changes
    argocd.argoproj.io/sync-options: Replace=true
    # Validate resource before syncing
    argocd.argoproj.io/sync-options: Validate=true
data:
  config.json: |
    {
      "key": "value"
    }

```