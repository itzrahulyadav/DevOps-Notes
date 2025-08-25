1.  Install envoy using helm

```
helm install eg oci://docker.io/envoyproxy/gateway-helm --version v0.0.0-latest -n envoy-gateway-system --create-namespace
```

2. Wait for the resources to be ready
   
```
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available

```

3. Create a simple application that deploys our application and exposes it using a service

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: app
        image: gcr.io/google-samples/hello-app:1.0
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-svc
spec:
  selector:
    app: sample-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080

```

4. Create a gateway class

```
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy-gateway-class
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller

```

5. Create gateway api using envoy

```
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: my-gateway
spec:
  gatewayClassName: envoy-gateway-class
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: Same
---
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: sample-app-route
spec:
  parentRefs:
  - name: my-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: sample-app-svc
      port: 80

```

6. Get the external ip of the load balancer

```
export GATEWAY_HOST=$(kubectl get gateway/my-gateway -o jsonpath='{.status.addresses[0].value}')

```


7. access the app using the external ip from your browser


## Traffic splitting in envoy

1. Let's create another version of our application sample-appv2.yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample-app-v2
  template:
    metadata:
      labels:
        app: sample-app-v2
    spec:
      containers:
      - name: app
        image: gcr.io/google-samples/hello-app:2.0 # Note the version is 2.0
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-svc-v2
spec:
  selector:
    app: sample-app-v2
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080


```

2. Edit the gateway.yaml file

```
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: sample-app-route
spec:
  parentRefs:
  - name: my-gateway
rules:
- backendRefs:
  - name: sample-app-svc  # The original v1 service
    port: 80
    weight: 90           # Send 90% of traffic here
  - name: sample-app-svc-v2 # The new v2 service
    port: 80
    weight: 10           # Send 10% of traffic here


```


## Header-Based Routing

This capability allows you to direct traffic to different backend services based on the HTTP headers present in the incoming request

Step 1: Modify the HTTPRoute for Header-Based Routing
We need to change the logic of our HTTPRoute. Instead of splitting traffic by weight, we will create two distinct rules. The router will process rules in order, so the first rule that matches an incoming request will be used.

update the gateway.yaml file

```

apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: sample-app-route
spec:
  parentRefs:
  - name: my-gateway
  rules:
  - matches: # Rule 1: For internal users
    - headers:
      - type: Exact
        name: X-User-Type
        value: internal
    backendRefs:
    - name: sample-app-svc-v2 # Route to v2
      port: 80
  - backendRefs: # Rule 2: Default rule for everyone else
    - name: sample-app-svc # Route to v1
      port: 80

```

Step 2. Get the external ip of the load balancer
```
export GATEWAY_HOST=$(kubectl get gateway/my-gateway -o jsonpath='{.status.addresses[0].value}')

```
Step 3. Make a curl request without header

`curl http://${GATEWAY_HOST}/ `


Step 4. Make a curl request with header

`curl -H "X-User-Type: internal" http://${GATEWAY_HOST}/`


## Rate Limiting

1. Envoy Gateway uses a resource called BackendTrafficPolicy. This policy allows us to attach rules directly to a service.

Step 1. Create a rate limit policy.yaml

```
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: BackendTrafficPolicy
metadata:
  name: sample-app-rate-limit
spec:
  targetRef:
    group: ""
    kind: Service
    name: sample-app-svc # This policy targets our v1 service
  rateLimit:
    type: Global
    global:
      rules:
      - limit:
          requests: 3
          unit: Minutes

```

2. Get the external ip

```
export GATEWAY_HOST=$(kubectl get gateway/my-gateway -o jsonpath='{.status.addresses[0].value}')

```

3. Run a loop to hit the service

```
for i in {1..7}; do
  echo "Request $i:"
  curl -I http://${GATEWAY_HOST}/
  sleep 1 # A small sleep to avoid overwhelming the shell
done

```

   
