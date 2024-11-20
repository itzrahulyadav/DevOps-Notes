### Control plane logs
- These are used to log details about control plane components
- Kubernetes API server component logs (api) – Your cluster's API server is the control plane component that exposes the Kubernetes API.
- Audit (audit) – Kubernetes audit logs provide a record of the individual users, administrators, or system components that have affected your cluster.
- Authenticator (authenticator) – Authenticator logs are unique to Amazon EKS. These logs represent the control plane component that Amazon EKS uses for Kubernetes Role Based Access Control (RBAC) authentication using IAM credentials.
- Controller manager (controllerManager) – The controller manager manages the core control loops that are shipped with Kubernetes.
- Scheduler (scheduler) – The scheduler component manages when and where to run pods in your cluster.

- Control plane logging can be enabled using the following command and also through console
  
```
aws eks update-cluster-config \
    --region $AWS_REGION \
    --name $EKS_CLUSTER_NAME \
    --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}'
```

- The logs are stored at /aws/eks/* log groups
- Log insights can be used to find the error
```
fields userAgent, requestURI, @timestamp, @message
| filter @logStream ~= "kube-apiserver-audit"
| stats count(userAgent) as count by userAgent
| sort count desc

```



### Pod logging
- Kubernetes, by itself, doesn’t provide a native solution to collect and store logs. It configures the container runtime to save logs in JSON format on the local filesystem.
 Container runtime – like Docker – redirects container’s stdout and stderr streams to a logging driver.
 In Kubernetes, container logs are written to /var/log/pods/*.log on the node. Kubelet and container runtime write their own logs to /var/logs or to journald, in operating systems with systemd.
 Then cluster-wide log collector systems like Fluentd can tail these log files on the node and ship logs for retention.
 These log collector systems usually run as DaemonSets on worker nodes.

- Logging agents like fluentbit can be used to send pod level logs to cloudwatch or kinesis data firehose
- ECR image for fluentbit `public.ecr.aws/aws-observability/aws-for-fluent-bit:init-debug-latest`
- It can be run as a Daemonset in nodes and will send logs to cloudwatch
- Run the following command to setup fluentbit in the cluster
```
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml

```
```
ClusterName=cluster-name
RegionName=cluster-region
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
kubectl create configmap fluent-bit-cluster-info \
--from-literal=cluster.name=${ClusterName} \
--from-literal=http.server=${FluentBitHttpServer} \
--from-literal=http.port=${FluentBitHttpPort} \
--from-literal=read.head=${FluentBitReadFromHead} \
--from-literal=read.tail=${FluentBitReadFromTail} \
--from-literal=logs.region=${RegionName} -n amazon-cloudwatch

```

```
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml

```
