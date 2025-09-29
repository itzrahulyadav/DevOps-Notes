1. helm repo add jenkins https://charts.jenkins.io
2. helm repo update
3. kubectl create namespace jenkins

4. Create a values.yaml

```
persistence:
  enabled: true
  storageClass: "standard"
  size: 8Gi

service:
  type: LoadBalancer
  port: 8080

```

5. helm install my-jenkins jenkins/jenkins --namespace jenkins -f values.yaml
6. printf $(kubectl get secret --namespace jenkins my-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode); echo


## Manually

1. kubectl create namespace jenkins
2. Create service-account.yaml

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins-admin
rules:
  - apiGroups: [""]
    resources: ["*"]
    verbs: ["*"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-admin
  namespace: jenkins
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins-admin
subjects:
- kind: ServiceAccount
  name: jenkins-admin
  namespace: jenkins

```

3. Create vpc.yaml

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pv-claim
  namespace: jenkins
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi

```

4. Create deployment.yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins-server
  template:
    metadata:
      labels:
        app: jenkins-server
    spec:
      securityContext:
        fsGroup: 1000
        runAsUser: 1000
      serviceAccountName: jenkins-admin
      containers:
        - name: jenkins
          image: jenkins/jenkins:lts
          resources:
            limits:
              memory: "2Gi"
              cpu: "1000m"
            requests:
              memory: "500Mi"
              cpu: "500m"
          ports:
            - name: httpport
              containerPort: 8080
            - name: jnlpport
              containerPort: 50000
          volumeMounts:
            - name: jenkins-persistent-storage
              mountPath: /var/jenkins_home
      volumes:
        - name: jenkins-persistent-storage
          persistentVolumeClaim:
            claimName: jenkins-pv-claim
```

5. Create service.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
  namespace: jenkins
  annotations:
    networking.gke.io/load-balancer-type: "Internal"  # Optional: Use "External" if needed
spec:
  type: LoadBalancer
  ports:
    - port: 8080
      targetPort: 8080
      protocol: TCP
  selector:
    app: jenkins-server

```
