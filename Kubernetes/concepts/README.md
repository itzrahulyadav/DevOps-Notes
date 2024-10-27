### Kubernetes architecture:

1.  Kube-scheduler

- It identifies the right node to place the pod on based on the pod requirement ,worker node capacity ,taint & tolerations.
- It does not place the pods on the nodes ,it just decides which node to go for,the pods are actually placed by kubelet.
- 

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
