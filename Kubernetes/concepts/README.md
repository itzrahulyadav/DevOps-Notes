### Kubernetes architecture:

1.  Kube-scheduler

- It identifies the right node to place the pod on based on the pod requirement ,worker node capacity ,taint & tolerations.
- It does not place the pods on the nodes ,it just decides which node to go for,the pods are actually placed by kubelet.
- 

2. Controller - manager
  - Node Controller
  - Replication controller
## Node Controller
- continuously watches the status of the nodes
- takes actions to remediate situation
- A controller is a process that continuously monitors the state of different components and works towards bringing the whole system to the desired working state.
- Node contoller monitors the node through kube-apisever.


## Replication controller
- It is responsible for monitoring the state of replica set and ensuring the desired number of pods are available at all time.

- 
3. 
