## Helm

1. start by installing helm
    - snap install helm --classic
    - snap install tree

2. Create a helm chart `helm create demo`
3. See the structure using tree `/usr/bin/tree demo`
4. cd `demo/template` and delete everything `rm -rf *`
5. Create a configmap yaml

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
