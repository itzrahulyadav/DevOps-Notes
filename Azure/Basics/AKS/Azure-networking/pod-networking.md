# AKS CIDR Planning and How CIDRs Work in AKS

## 🔹 Best Practices for CIDR Planning in AKS

When you create an AKS cluster, you need to consider **3 main address spaces**:

1. **VNet / Subnet CIDRs**  
   - Real Azure subnets in your VNet (like in AWS VPC).  
   - Your **node pools (VMs)** sit here.  
   - Example: `10.0.0.0/16` for VNet, `10.0.1.0/24` for AKS subnet.

2. **Service CIDR** (virtual, cluster-internal)  
   - A **virtual CIDR** used to allocate **ClusterIP services** (like Kubernetes services).  
   - Not tied to your VNet or subnets. It only exists inside kube-proxy/iptables/ebpf on nodes.  
   - Example: `10.2.0.0/16` with DNS at `10.2.0.10`.  
   - Must **NOT overlap** with VNet/subnet ranges.

3. **Pod CIDR**  
   - Depends on network plugin:  
     - **kubenet** → Pod IPs are NAT’d, allocated from a separate CIDR (e.g., `10.244.0.0/16`).  
     - **Azure CNI** → Each pod gets a real IP from the **subnet** (e.g., `10.0.1.0/24`). That’s why you need a large enough subnet to hold nodes *and* pods.  

---

## 🔹 How the CIDRs Work Inside AKS

- **Service CIDR**:  
  - Virtual. Not carved from your VNet.  
  - IPs assigned here never leave the cluster.  
  - For example, when you create a `ClusterIP` service, Kubernetes allocates one IP (say `10.2.0.50`) from the Service CIDR.  
  - kube-proxy maps that virtual IP → backend pod endpoints.  
  - Only routable inside the cluster.  

- **Pod CIDR**:  
  - If using **Azure CNI**: Pod IPs are taken directly from the **subnet CIDR** linked to your AKS cluster.  
  - If using **kubenet**: Pod IPs are allocated from a separate CIDR (overlay), not your subnet. NAT is used for egress.  

- **Node Subnet CIDR**:  
  - Real IPs from the VNet subnet. Each VM/node sits here.  

---

## 🔹 Example Layout (Best Practice)

Let’s say you allocate `10.0.0.0/16` for the VNet.  

- **Subnet for AKS nodes**: `10.0.0.0/20` (4096 IPs for nodes + pods in Azure CNI mode).  
- **Subnet for other services (DB, app VMs, etc.)**: `10.0.16.0/20`  
- **Service CIDR (virtual, AKS only)**: `10.2.0.0/16`  
- **DNS service IP**: `10.2.0.10` (inside service CIDR).  
- **Pod CIDR** (only if kubenet): `10.244.0.0/16`  

---

## 🔹 Best Practices Summary

✅ **Service CIDR**  
- Always pick a CIDR **non-overlapping** with your VNets or on-prem networks.  
- `/16` is usually enough (`65k services`).  

✅ **Pod CIDR (if kubenet)**  
- Also must be non-overlapping with VNet/on-prem.  
- `/16` works well for large clusters.  

✅ **Subnets**  
- If using **Azure CNI**, size your subnets large enough to hold:  
  - 1 IP per node  
  - 1 IP per pod scheduled on that node  
  - Some buffer (Azure reserves 5 IPs per subnet).  
- Rule of thumb: `/23` or bigger per nodepool subnet for production.  

✅ **Consistency**  
- Reserve different address spaces for services, pods, and subnets — just like you’d separate subnets in AWS.  

---

## 🔹 Direct Answer to "How Does It Work?"

- The **Service CIDR is *virtual***. It is not carved from your cluster subnet.  
- Pod IP allocation depends on plugin:  
  - **Azure CNI** → Pods consume subnet IPs.  
  - **kubenet** → Pods get IPs from a virtual pod CIDR, NAT’d to the node subnet.  
