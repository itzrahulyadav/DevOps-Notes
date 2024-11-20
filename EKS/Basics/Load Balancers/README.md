### Load balancer controller 
- It's responsible for provisioning the following resources
   - ALB(for ingress)
   - NLB (for kubernetes service of type kubernetes)

### Exposing the pods using service LoadBalancer

- OICD must be available for the cluster
- Create proper permission for the load balancer to use
```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json


eksctl create iamserviceaccount \
  --cluster=my-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

```

- Install the load balancer controller using helm

```
helm repo add eks-charts https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller


```

- Check if the controller is installed  ` kubectl get deployment -n kube-system aws-load-balancer-controller`
- Create a service and check that the load balancer gets provisioned

```
apiVersion: v1
kind: Service
metadata:
  name: ui-nlb
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: external
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: instance
  namespace: ui
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8080
      name: http
  selector:
    app.kubernetes.io/name: ui
    app.kubernetes.io/instance: ui
    app.kubernetes.io/component: service
```

- The NLB can also be used to send traffic using IP mode
- Just configure the annotation  `service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip`

### Exposing the pods using ingress

- Just install the load balancer controller and create the resource of type ingress

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ui
  namespace: ui
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-path: /actuator/health/liveness
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ui
                port:
                  number: 80

```
- Use multiple ingress pattern to use same alb for multiple services
- Use the following annotation  `alb.ingress.kubernetes.io/group.name: retail-app-group`
  
  
