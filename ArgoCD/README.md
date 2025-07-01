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

      - PruneLast: true
      # Create namespace if it doesn't exist
      - CreateNamespace=true
      
      # ArgoCD sync resourcs with out of sync only
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



# Resource-Level Prune in ArgoCD
#
# Resource-level pruning allows fine-grained control over how individual Kubernetes resources
# are removed when they are no longer present in the Git repository. This can be configured
# using annotations on specific resources to:
#
# - Prevent specific resources from being pruned
# - Control the order of pruning
# - Set custom propagation policies
# - Enable selective pruning based on labels
#
# The prune behavior can be controlled using the following annotations:
# - argocd.argoproj.io/sync-options: Prune=false|true
# - argocd.argoproj.io/sync-options: PruneLast=true 
# - argocd.argoproj.io/sync-options: PrunePropagationPolicy=foreground|background
#
# This provides more granular control compared to application-level pruning settings.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-deployment
  annotations:
    argocd.argoproj.io/sync-options: Prune=false
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
        image: nginx:1.19

# Example demonstrating resource-level prune options in ArgoCD

# 1. Disable pruning for specific resource using annotation
apiVersion: apps/v1
kind: Deployment
metadata:
  name: no-prune-deployment
  annotations:
    argocd.argoproj.io/sync-options: Prune=false  # Prevents this deployment from being pruned
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
        image: nginx:1.19

---
# 2. Enable pruning with custom propagation policy
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: prune-statefulset
  annotations:
    argocd.argoproj.io/sync-options: PrunePropagationPolicy=foreground
spec:
  serviceName: example
  replicas: 2
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
        image: nginx:1.19

---
# 3. Prune last - resource will be pruned after all other resources are synced
apiVersion: v1
kind: Service
metadata:
  name: prune-last-service
  annotations:
    argocd.argoproj.io/sync-options: PruneLast=true
spec:
  selector:
    app: example
  ports:
  - port: 80
    targetPort: 80

---
# 4. Selective pruning with labels
apiVersion: v1
kind: ConfigMap
metadata:
  name: selective-prune-config
  labels:
    prune-safe: "true"  # Custom label to control pruning
  annotations:
    argocd.argoproj.io/sync-options: Prune=true
data:
  config.json: |
    {
      "key": "value"
    }



# Selective Sync in ArgoCD
# Selective sync allows you to sync only specific resources within an application
# rather than syncing the entire application. This can be controlled through:
# 1. Resource inclusion/exclusion
# 2. Label selectors
# 3. Resource tracking method

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: selective-sync-demo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/repo.git
    targetRevision: HEAD
    path: k8s
    
    # Define which resources to include/exclude during sync
    directory:
      include: "*.yaml"  # Only sync yaml files
      exclude: "secrets.*" # Exclude secrets
      
    # Use label selector to sync only resources with specific labels  
    selector:
      matchLabels:
        sync: "true"
        
  destination:
    server: https://kubernetes.default.svc
    namespace: demo
    
  # Configure sync options
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - ApplyOutOfSyncOnly=true # Only sync resources that are out of sync
      
---
# Example resources that will be selectively synced based on labels

apiVersion: apps/v1
kind: Deployment
metadata:
  name: included-deployment
  labels:
    sync: "true"  # This deployment will be synced
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: nginx
        image: nginx:latest

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: excluded-deployment
  labels:
    sync: "false" # This deployment will be excluded from sync
spec:
  replicas: 2
  selector:
    matchLabels: 
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: nginx
        image: nginx:latest

---
# Resource tracking method example
apiVersion: v1
kind: ConfigMap
metadata:
  name: tracked-config
  annotations:
    # Track this resource by name only
    argocd.argoproj.io/tracking-method: name
data:
  key: value 


# Fail on Shared Resources in ArgoCD
#
# This feature prevents multiple applications from managing the same Kubernetes resources
# to avoid conflicts and unintended modifications. When enabled, ArgoCD will fail 
# synchronization if it detects that a resource is managed by multiple applications.
#
# To enable this feature, use the 'failOnSharedResource' sync option.

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app1
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/repo.git
    targetRevision: HEAD
    path: app1
  destination:
    server: https://kubernetes.default.svc
    namespace: shared-ns
  syncPolicy:
    syncOptions:
      - FailOnSharedResource=true # Will fail sync if resources are shared
    automated:
      prune: true
      selfHeal: true

---
# Another application trying to manage same resources
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app2
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/repo.git
    targetRevision: HEAD 
    path: app2
  destination:
    server: https://kubernetes.default.svc
    namespace: shared-ns # Same namespace as app1
  syncPolicy:
    syncOptions:
      - FailOnSharedResource=true
    automated:
      prune: true
      selfHeal: true

---
# Example shared resource that would cause sync failure
apiVersion: v1
kind: ConfigMap
metadata:
  name: shared-config
  namespace: shared-ns
data:
  key: value



# Replace Resources in ArgoCD
#
# The Replace sync option forces ArgoCD to delete and recreate resources instead of 
# patching them. This is useful when:
# - Resources cannot be patched and must be recreated
# - You want to ensure a clean state for the resource
# - Complex updates require full replacement
#
# Can be configured at:
# 1. Application level using syncOptions
# 2. Individual resource level using annotations

# Example showing Replace sync option

# 1. Application level Replace
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: replace-demo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/repo.git
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: demo
  syncPolicy:
    syncOptions:
      - Replace=true    # Enable replace for all resources

---
# 2. Resource level Replace using annotation
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-to-replace
  annotations:
    argocd.argoproj.io/sync-options: Replace=true  # This config map will be replaced instead of patched
data:
  key1: value1
  key2: value2






# ArgoCD Diffing Customization
#
# Diffing customization allows you to control how ArgoCD compares resources between 
# Git and the live cluster state. This can be configured using:
# 1. ignoreDifferences in Application spec
# 2. Resource-level annotations
# 3. Common customization patterns

# Example showing different diffing customization approaches

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: diff-customization-demo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/repo.git
    targetRevision: HEAD
    path: manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: demo
    
  # Application-level diff customization
  ignoreDifferences:
  # Ignore differences in replica count
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas
    
  # Ignore differences in specific fields
  - group: ""
    kind: Service
    jsonPointers:
    - /spec/clusterIP
    - /metadata/annotations/service.beta.kubernetes.io/*
    
  # Ignore differences using JQ expressions  
  - group: apps
    kind: Deployment
    jqPathExpressions:
    - .spec.template.spec.containers[] | select(.name == "nginx").image

---
# Resource-level diff customization using annotations
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  annotations:
    # Ignore container image tags
    argocd.argoproj.io/compare-options: IgnoreExtraneous
    # Ignore specific fields
    argocd.argoproj.io/compare-options: JsonPointers=/spec/replicas,/metadata/annotations
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest

---
# Example showing common customization patterns
apiVersion: v1
kind: Service
metadata:
  name: demo-service
  annotations:
    # Ignore system-generated fields
    argocd.argoproj.io/compare-options: IgnoreExtraneous
    # Custom diff normalization
    argocd.argoproj.io/compare-options: NormalizeEmpty
spec:
  selector:
    app: demo
  ports:
  - port: 80
    targetPort: 80





# ArgoCD Sync Phases and Hooks
# Sync phases define the order of resource synchronization
# Hooks allow running custom actions before, during, or after sync

# Example showing sync phases and hooks
apiVersion: batch/v1
kind: Job
metadata:
  name: pre-sync-job
  annotations:
    argocd.argoproj.io/hook: PreSync # Executes before sync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded # Delete after successful execution
spec:
  template:
    spec:
      containers:
      - name: pre-sync
        image: busybox
        command: ["sh", "-c", "echo 'Running pre-sync tasks'"]
      restartPolicy: Never

---
apiVersion: batch/v1
kind: Job
metadata:
  name: sync-job
  annotations:
    argocd.argoproj.io/hook: Sync # Executes during sync
    argocd.argoproj.io/sync-wave: "1" # Controls execution order
spec:
  template:
    spec:
      containers:
      - name: sync
        image: busybox
        command: ["sh", "-c", "echo 'Running sync tasks'"]
      restartPolicy: Never

---
apiVersion: batch/v1
kind: Job
metadata:
  name: post-sync-job
  annotations:
    argocd.argoproj.io/hook: PostSync # Executes after sync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
      - name: post-sync
        image: busybox
        command: ["sh", "-c", "echo 'Running post-sync tasks'"]
      restartPolicy: Never

---
# Available Hook Types:
# - PreSync: Runs before sync
# - Sync: Runs during sync
# - PostSync: Runs after sync
# - SyncFail: Runs if sync fails
# - Skip: Resource is not synced

# Hook Delete Policies: 
# - HookSucceeded: Delete after successful execution
# - HookFailed: Delete after failed execution
# - BeforeHookCreation: Delete before creating new hook




# ArgoCD Sync Waves
# Sync waves control the order of resource synchronization within an application.
# Resources are synced in ascending order based on their wave number.
# Resources in the same wave are synced in parallel.
# Default wave number is 0 if not specified.

# Example 1: Basic Sync Wave Order
apiVersion: v1
kind: Namespace
metadata:
  name: example
  annotations:
    argocd.argoproj.io/sync-wave: "-1" # Runs first
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  annotations:
    argocd.argoproj.io/sync-wave: "0" # Runs second
data:
  config.json: |
    {
      "key": "value"
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
  annotations:
    argocd.argoproj.io/sync-wave: "1" # Runs third
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
# Example 2: Complex Application Deployment with Sync Waves

# Wave -2: Create Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: complex-app
  annotations:
    argocd.argoproj.io/sync-wave: "-2"

---
# Wave -1: Create Secrets and ConfigMaps
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: complex-app
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
type: Opaque
data:
  api-key: YWJjMTIz

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: complex-app
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
data:
  settings.conf: |
    environment=production
    debug=false

---
# Wave 0: Create Services
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: complex-app
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  selector:
    app: complex-app
  ports:
  - port: 80
    targetPort: 8080

---
# Wave 1: Deploy Database
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
  namespace: complex-app
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  serviceName: database
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: postgres
        image: postgres:13

---
# Wave 2: Deploy Application
apiVersion: apps/v1
kind: Deployment
metadata:
  name: application
  namespace: complex-app
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: complex-app
  template:
    metadata:
      labels:
        app: complex-app
    spec:
      containers:
      - name: app
        image: myapp:1.0

---
# Wave 3: Deploy Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: complex-app
  annotations:
    argocd.argoproj.io/sync-wave: "3"
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80

---
# Wave 4: Post-deployment Jobs
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  namespace: complex-app
  annotations:
    argocd.argoproj.io/sync-wave: "4"
    argocd.argoproj.io/hook: PostSync
spec:
  template:
    spec:
      containers:
      - name: migration
        image: migration-tool:1.0
      restartPolicy: Never