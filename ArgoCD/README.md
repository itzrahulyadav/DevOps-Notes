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
    repoURL: https://github.com/myorg/myapp.git
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp
  syncPolicy:
    automated:
      prune: true
      selfHeal: true

# Apply using:
# kubectl apply -f application.yaml

# Method 2: Using ArgoCD CLI
# Command format:
argocd app create myapp \
  --repo https://github.com/myorg/myapp.git \
  --path k8s \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace myapp \
  --sync-policy automated \
  --auto-prune \
  --self-heal