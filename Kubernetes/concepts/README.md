### Kubernetes architecture:

1.  Kube-scheduler

- It identifies the right node to place the pod on based on the pod requirement ,worker node capacity ,taint & tolerations.

2. Controller - manager
  - Node Controller
  - Replication controller
- continuously watches the status of the nodes
- takes actions to remediate situation
- A controller is a process that continuously monitors the state of different components and works towards bringing the whole system to the desired working state.
- Node contoller monitors the node through kube-apisever.

3. 
