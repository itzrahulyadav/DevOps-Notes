### Network policies
- Network policies are virtual firewall, allowing you to segment and secure your cluster by specifying ingress (incoming) and egress (outgoing) network traffic rules based on various
  criteria such as pod labels, namespaces, IP addresses, and ports.
  
- Here's an example network policy
```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - ipBlock:
            cidr: 172.17.0.0/16
            except:
              - 172.17.1.0/24
        - namespaceSelector:
            matchLabels:
              project: myproject
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 6379
  egress:
    - to:
        - ipBlock:
            cidr: 10.0.0.0/24
      ports:
        - protocol: TCP
          port: 5978

```

### Pod security groups
- By default every Pod on a node shares the same security groups as the node it runs on
- You can enable security groups for Pods by setting ENABLE_POD_ENI=true for VPC CNI `kubectl set env daemonset aws-node -n kube-system ENABLE_POD_ENI=true`
- When you enable Pod ENI, the VPC Resource Controller running on the control plane (managed by EKS) creates and attaches a
  trunk interface called “aws-k8s-trunk-eni“ to the node. The trunk interface acts as a standard network interface attached to the instance.
- Run the following command to check the changes applied to the nodes `kubectl get cninode -A`

