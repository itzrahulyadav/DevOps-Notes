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

- To attach a security group to a pod follow the steps below:
   - Create a sg
   - Crate a CRD of type security group policy
     ```
     apiVersion: vpcresources.k8s.aws/v1beta1
     kind: SecurityGroupPolicy
     metadata:
       name: my-security-group-policy
     namespace: my-namespace
     spec:
       podSelector:
        matchLabels:
          role: my-role
       securityGroups:
          groupIds:
          - my_pod_security_group_id
  ```

### Custom Networking
- Suppose we have a VPC with 2 CIDRs Primary : 10.42.0.0/16 and secondary : 100.64.0.0/16.
- Creating a pod will assign an IP from primary cidr but we can use custom networking to use the CIDR from the secondary CIDR.
- To enable custom networking we have to set the AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG environment variable to true in the aws-node DaemonSet.
  `kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true`
  
- create an ENIConfig custom resource for each subnet that pods will be deployed in:
```
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: ${SUBNET_AZ_1}
spec:
  securityGroups:
    - ${EKS_CLUSTER_SECURITY_GROUP_ID}
  subnet: ${SECONDARY_SUBNET_1}
---
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: ${SUBNET_AZ_2}
spec:
  securityGroups:
    - ${EKS_CLUSTER_SECURITY_GROUP_ID}
  subnet: ${SECONDARY_SUBNET_2}
---
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: ${SUBNET_AZ_3}
spec:
  securityGroups:
    - ${EKS_CLUSTER_SECURITY_GROUP_ID}
  subnet: ${SECONDARY_SUBNET_3}
```
- Run the following command: `kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone`

### VPC Prefix delegation
- This feature allows us to add CIDR prefexis to the nodes instead of IPs.
- Check the CNI version `kubectl describe daemonset aws-node --namespace kube-system | grep Image | cut -d "/" -f 2`
- Check if the prefix delegation is true ` kubectl get ds aws-node -o yaml -n kube-system | yq '.spec.template.spec.containers[].env'`
- To check the prefixis assigned to the cluster, run the following command
```
aws ec2 describe-instances --filters "Name=tag-key,Values=eks:cluster-name" \
  "Name=tag-value,Values=${EKS_CLUSTER_NAME}" \
  --query 'Reservations[*].Instances[].{InstanceId: InstanceId, Prefixes: NetworkInterfaces[].Ipv4Prefixes[]}'
```



### VPC Lattice

- The components of Amazon VPC Lattices include:
  
   - Service network: A shareable, managed logical grouping that contains Services and Policy.
   - Service: Represents an Application Unit with a DNS name and can extend across all compute – instances, containers, serverless. It is made up of Listener, Target Groups, Target.
   - Service directory: A registry within an AWS account that holds a global view of Services by version and their DNS names.
   - Auth policies: A declarative policy that determines how Services are permitted to communicate. These can be defined at the Service level or the Service Network level.

- 
