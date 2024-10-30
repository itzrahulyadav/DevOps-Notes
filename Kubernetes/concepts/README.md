### Kubernetes architecture:

1.  Kube-scheduler

- It identifies the right node to place the pod on based on the pod requirement ,worker node capacity ,taint & tolerations.
- It does not place the pods on the nodes ,it just decides which node to go for,the pods are actually placed by kubelet.

  

2. Controller - manager
  - Node Controller
  - Replication controller
  - namespace controller,job controller, endpoint controller

## Node Controller
- continuously watches the status of the nodes
- takes actions to remediate situation
- A controller is a process that continuously monitors the state of different components and works towards bringing the whole system to the desired working state.
- Node contoller monitors the node through kube-apisever.


## Replication controller
- It is responsible for monitoring the state of replica set and ensuring the desired number of pods are available at all time.


3.  Kubeapiserver
  - Exposes kubernetes api. It's a frontend for kubernetes control plane
    
4. ETCD
  -  key-value store used as kubernetes database for storing all cluster data
  - It stores the state of the cluster
  - Api server communicates with the ETCD data store to provide and store the important information.

5. Cloud control manager
  - Links kubernetes cluster into cloud provider's APIs such as Node controller for determining if node (instance) is deleted in the cloud.
  - Integrate ALB and NLB with the kuberenetes


## Data plane components

1. Nodes
   - This are just virtual machines that run the pods

2. Kubelet
   - It's an agent which communicates with the container runtime and make the pods run in the nodes
   - It reports pod failures to the kube-apiserver
  
3. kube-proxy
   - It enables network communication between the pods
   - Also help exposing pods using services
4. container runtime
   - responsible for running containers
   - k8s supports containerD, crio and other container runtimes like rocket
  
Control plane architecture:

<img width="993" alt="Screenshot 2024-10-28 at 10 12 43 PM" src="https://github.com/user-attachments/assets/f8e28d98-c2f4-4eca-82b4-49b92b212d92">




Networking in EKS:

Few points to consider :

- AWS control plane is launched in AWS managed account and VPC
- Data plane nodes are launched in customer managed account & vpc
- Although the control plane is launched in AWS vpc but the ENIs are launched in customer VPC and that's how the communication between control plane and data plane happens.
- It is recommended to have seperate subnets for EKS ENIs. EKS ENIs need to have 6 IPs in each subnet
- EKS creates default security groups and associates to these ENIs
- kube-apiserver can be accessed over the internet
- Dual stack mode is not allowed for pods, either ipv4 or ipv6

EKS architecture

- If EKS cluster endpoint access (public is enabled) then the worker nodes will communicate with the control plane over the internet and for that to happen the worker nodes must be in public subnet and have internet gateway attached to it.
- But it can be restricted , we can specify the CIDR block to who can connect to the control plane (whitelist the worker nodes subnet IP)
-  We can enable public and private access using which users can connect to controlplane from public internet while the worker node will connect using the private enis created in our subnet
-  The public endpoint access can be disabled altogether but then we should have some sort of layer 4 connection like DX or AWS VPN to connect. It will connect to eks owned enis and allow communication with control plane
-  Seperate public subnet is required if we want to expose our services.Load balancers and NAT gateways will be launched in the public subnet.
-  AWS VPC endpoint privatelink can be used to access other AWS services.


### POD Networking

 #### CNCF network specifications: (CNI)
 
 - Every pod has it's own IP
 - Containers in the same POD share the same network address
 - All pods can communicate with other pod without the use of NAT
 - All nodes can communicate with other pods without the use of NAT

 #### Amazon VPC CNI plugin

 - CNI plugin attaches ENI to the worker nodes
 - ENI consists of one primary address (assigned to node) and multiple secondary ip addresses (for PODS)
 - This also depends on ec2 instance type.
 - EKS supports VPC CNI plugin but we can also integrate 3rd party CNIs like calico,cilium,Weave net etc.

   ##### Maximum pods per node
   - It depends on how many CNIs can be attached
   - Total pods = no: of ENIs that can be attached * (max IPs per network interfaces - 1) + 2(this is used by aws for kubeproxy and host network)
     
   #### Prefix delegation
   - It allows to assign CIDR to the ENIs (so instead of ips we can assign entire CIDR)
   - /28 can be used for ipv4
   
 






