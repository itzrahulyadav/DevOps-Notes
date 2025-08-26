 ### We will see how canary deployment works

1. Create an application with 2 versions running.
   
```
# Version 1 of our backend application
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
      version: v1
  template:
    metadata:
      labels:
        app: backend
        version: v1
    spec:
      containers:
      - name: backend
        image: jmalloc/echo-server
        ports:
        - containerPort: 8080
        env:
        - name: ECHO_TEXT
          value: "Response from v1"
---
apiVersion: v1
kind: Service
metadata:
  name: backend-v1-svc
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: backend
    version: v1

---

# Version 2 of our backend application (the canary)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
      version: v2
  template:
    metadata:
      labels:
        app: backend
        version: v2
    spec:
      containers:
      - name: backend
        image: jmalloc/echo-server
        ports:
        - containerPort: 8080
        env:
        - name: ECHO_TEXT
          value: "Response from v2 (CANARY)"
---
apiVersion: v1
kind: Service
metadata:
  name: backend-v2-svc
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: backend
    version: v2

```

2 . Create the configmap for Envoy pod - envoy-configmap.yaml

```

apiVersion: v1
kind: ConfigMap
metadata:
  name: client-envoy-config
data:
  envoy.yaml: |
    static_resources:
      listeners:
      - name: outbound_listener
        address:
          socket_address: { address: 127.0.0.1, port_value: 9000 }
        filter_chains:
        - filters:
          - name: envoy.filters.network.http_connection_manager
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
              stat_prefix: outbound_http
              route_config:
                name: local_route
                virtual_hosts:
                - name: backend_service
                  domains: ["*"]
                  routes:
                  - match: { prefix: "/" }
                    route:
                      # This is the key for canary routing!
                      weighted_clusters:
                        clusters:
                        - name: backend_v1_cluster
                          weight: 90
                        - name: backend_v2_cluster
                          weight: 10
              http_filters:
              - name: envoy.filters.http.router
                typed_config:
                  "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
      clusters:
      - name: backend_v1_cluster
        connect_timeout: 0.25s
        type: STRICT_DNS
        lb_policy: ROUND_ROBIN
        load_assignment:
          cluster_name: backend_v1_cluster
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    # Note: We use the FQDN of the Kubernetes service
                    address: backend-v1-svc.default.svc.cluster.local
                    port_value: 80
      - name: backend_v2_cluster
        connect_timeout: 0.25s
        type: STRICT_DNS
        lb_policy: ROUND_ROBIN
        load_assignment:
          cluster_name: backend_v2_cluster
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: backend-v2-svc.default.svc.cluster.local
                    port_value: 80

```


3. Create the client pod

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: client
spec:
  replicas: 1
  selector:
    matchLabels:
      app: client
  template:
    metadata:
      labels:
        app: client
    spec:
      containers:
      - name: client-app
        image: curlimages/curl
        # Keep the container alive
        command: ["sleep", "infinity"]
      - name: envoy
        image: envoyproxy/envoy:v1.28.0
        args:
        - "envoy"
        - "-c"
        - "/etc/envoy/envoy.yaml"
        volumeMounts:
        - name: envoy-config-volume
          mountPath: /etc/envoy
      volumes:
      - name: envoy-config-volume
        configMap:
          name: client-envoy-config

```

4. Exec into client pod
   ```
   CLIENT_POD_NAME=$(kubectl get pods -l app=client -o jsonpath='{.items[0].metadata.name}')
   kubectl exec -it $CLIENT_POD_NAME -c client-app -- sh
   for i in $(seq 1 10); do curl http://localhost:9000; done

   ```




