## Helm

1. start by installing helm
    - snap install helm --classic
    - snap install tree

or
```sh

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

```

1. Create a helm chart `helm create demo`
2. See the structure using tree `/usr/bin/tree demo`
3. cd `demo/template` and delete everything `rm -rf *`
4. Create a configmap yaml

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: mychart-configmap
data:
  myvalue: "Hello Rebels"

```
7. use the dry run command to see the output  `helm install demo-chart --dry-run=client demo`
8. Modify the yaml file to add env variables

```
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: king-skeleton
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello Rebels"
```

9. Run the following command
```
helm install demo_chart demo

```
10. `helm get manifest king-skeleton`
11. That's it check the cm using  `k get cm --namespace`


####################
PART 2

1. Create a new directory called  `demo-app`
2. Create template directory inside demo-app so the full path will be /demo-app/template
3. Create values.yaml file inside the demo-app folder
    demo-app
        ------templates
        ------values.yaml
4. Create deployment.yaml inside the templates folder
     demo-app
        ------templates
              ------ deployment.yaml
        ------values.yaml
5. content of deployment.yaml
```
apiVersion: apps/v1
kind: Deployment
# we don't need to define a namespace, this is set in the current context
metadata:
  name: {{ .Chart.Name }}
  labels:
    app: {{ .Chart.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: busybox
        command: ["/bin/httpd"]
        args: ["-f", "-h", "/var/www/"]
        ports:
        - containerPort: 80
        volumeMounts:
        - name: working-dir
          mountPath: /var/www/
      volumes:
      - name: working-dir
        configMap:
          name: ks-{{ .Chart.Name }}-configmap

```
6. Create a Chart.yaml file inside the demo-app folder
    demo-app
        ------templates
              ------ deployment.yaml
        ------values.yaml
        ------Chart.yaml
7.Content of chart.yaml

```
apiVersion: v2
name: db
type: application
version: 0.1.0
appVersion: "1.1-SNAPSHOT"

```
8. Use helm template command do get the output `helm template demo-app`
9. `helm install my-chart demo-app`
10. use helm ls to see the charts `helm ls`
11. Use `helm get manifest my-chart` to see what is created
12. Use port forward to forward traffic to our system `kubectl port-forward --address 0.0.0.0 deployment/$APP_DEPLOY 8080:80 &`



# Helm Subcharts Notes:

# 1. Subcharts are charts that can be included inside another chart (parent chart)
# They allow modular and reusable chart components

# 2. Defined in parent chart's Chart.yaml under 'dependencies' section:
dependencies:
  - name: subchart        # Name of subchart
    version: x.x.x        # Version required
    repository: url       # Repository URL
    condition: flag       # Optional condition to enable/disable
    tags:                 # Optional tags for enabling/disabling groups
    import-values:        # Values to import from subchart

# 3. Key features:
# - Each subchart is independent and can have its own values
# - Parent chart can override subchart values
# - Subcharts can be enabled/disabled via conditions
# - Tags can enable/disable groups of charts
# - Values can be shared between parent and subcharts

# 4. Common commands:
# helm dependency update  # Download subcharts
# helm dependency build  # Rebuild charts/ directory
# helm dependency list   # List chart dependencies

# 5. Values precedence:
# - Parent chart values override subchart defaults
# - Global values are accessible to all subcharts
# - Each subchart maintains own values isolation

# Subcharts in Helm
# Chart.yaml
apiVersion: v2
name: parentchart
description: A Helm parent chart example
version: 0.1.0
dependencies:
  - name: subchart1
    version: 0.1.0
    repository: https://example.com/charts
  - name: subchart2 
    version: 1.2.3
    repository: https://another.example.com/charts
    condition: subchart2.enabled
    tags:
      - front-end
    import-values:
      - data

# values.yaml
subchart1:
  enabled: true
  config:
    key1: value1
    
subchart2:
  enabled: false
  config:
    key2: value2

tags:
  front-end: false

# Commands to manage dependencies
# helm dependency update
# helm dependency build
# helm dependency list


# Helm Webhooks Notes:

# Full documentation [Here](https://helm.sh/docs/topics/charts_hooks/)
# 1. Helm Webhooks are special hooks that execute at specific points during chart installation/upgrade:
# - pre-install   : Before templates are rendered
# - post-install  : After all resources are loaded into K8s
# - pre-delete    : Before deletion begins
# - post-delete   : After deletion completes
# - pre-upgrade   : Before upgrade begins
# - post-upgrade  : After upgrade completes
# - pre-rollback  : Before rollback starts
# - post-rollback : After rollback completes

# 2. Example webhook manifest:
apiVersion: batch/v1
kind: Job
metadata:
  name: pre-install-job
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "5"        # Defines execution order
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    spec:
      containers:
      - name: pre-install-job
        image: busybox
        command: ["/bin/sh", "-c", "echo pre-install"]
      restartPolicy: Never

# 3. Key webhook features:
# - Can be any valid Kubernetes resource
# - Multiple hooks of same type allowed
# - Weights control execution order
# - Delete policies control cleanup
# - Failed hooks block release progress

# 4. Common annotations:
# helm.sh/hook: <hook-name>           # Defines hook type
# helm.sh/hook-weight: <number>       # Sets priority (lower runs first)
# helm.sh/hook-delete-policy:         # Cleanup behavior
#   - hook-succeeded
#   - hook-failed  
#   - before-hook-creation

# 5. Best practices:
# - Use Jobs for hooks when possible
# - Set appropriate delete policies
# - Consider timeout settings
# - Add proper error handling
# - Use weights for dependencies
