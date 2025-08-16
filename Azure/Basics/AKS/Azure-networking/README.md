# Azure kubenet vs Azure CNI


# Azure CNI vs. Kubenet: A Comparison for AKS Networking

When setting up an Azure Kubernetes Service (AKS) cluster, one of the fundamental decisions is choosing the networking plugin. The two primary options are Azure CNI and Kubenet. This document outlines the key differences between them to help you choose the right model for your workload.

| Feature | Azure CNI | Kubenet |
| :--- | :--- | :--- |
| **IP Address Allocation** | Each pod gets a full-fledged IP address directly from the virtual network (VNet) subnet. [7] | Nodes get an IP address from the VNet, but pods receive IPs from a separate, logically isolated address space within each node. [5, 7] |
| **VNet Integration** | Pods are first-class citizens on the VNet, enabling seamless connectivity with other Azure resources. [4] | Pods are not directly addressable from the VNet. User-Defined Routes (UDRs) are required for communication outside the node. [5, 6] |
| **Performance** | Offers lower latency as there's no extra hop or Network Address Translation (NAT) for pod-to-pod communication within the VNet. [3, 5] | Communication to resources outside the node goes through an extra hop and NAT, which can introduce minor latency. [3, 7] |
| **IP Address Consumption** | Consumes a significant number of IP addresses from your VNet, as each pod requires one. [2] Careful planning is essential to avoid IP exhaustion. [7] | More conservative with VNet IP addresses since only the nodes consume them. [4] This can be beneficial in environments with limited IP space. |
| **Network Policies** | Supports both Azure Network Policies and Calico for enforcing network security rules. | Only supports Calico Network Policies. |
| **Supported Node Types**| Supports both Linux and Windows Server nodes. | Supports only Linux nodes. [7] |
| **Advanced Networking** | Enables advanced features like Virtual Nodes and Application Gateway Ingress Controller (AGIC). [7] | Does not support features that require direct pod VNet integration, like Virtual Nodes. |
| **Use Cases** | Ideal for high-performance workloads, scenarios requiring direct pod accessibility from other Azure services, and clusters with Windows nodes. [2, 3] | Suited for smaller clusters, development/test environments, or situations where conserving VNet IP addresses is a priority. [4] |
| **Simplicity** | Requires more upfront network planning and can be more complex to manage. [2, 7] | Simpler to set up and is the default networking option in AKS, making it good for getting started quickly. [3] |



### Azure CNI Overlay

Azure CNI Overlay is a networking model for Azure Kubernetes Service (AKS) designed to conserve IP address space within your Virtual Network (VNet).

#### How it Works

*   **Separate IP Spaces**: Cluster nodes get IPs from your VNet subnet, but pods are assigned IPs from a private CIDR range that is logically separate from the VNet.
*   **Overlay Network**: An overlay network is created for direct pod-to-pod communication within the cluster.
*   **NAT for External Access**: For traffic leaving the cluster, Network Address Translation (NAT) is used to translate the pod's private overlay IP to the node's VNet IP. This means external resources see the node's IP, not the pod's.

#### Key Benefits

*   **IP Address Conservation**: This is the primary advantage. It significantly reduces the number of VNet IP addresses consumed, which is crucial for large-scale clusters or in environments with limited IP space.
*   **Enhanced Scalability**: Allows you to scale your cluster to a large number of pods without quickly exhausting VNet IP addresses. You can have up to 250 pods per node by default.
*   **Simplified IP Planning**: Since the pod CIDR is separate, IP address management becomes simpler for most enterprise networking setups.
*   **Reusable Pod CIDR**: The same pod CIDR space can be used across multiple independent AKS clusters within the same VNet.

#### Limitations & Considerations

*   **Application Gateway Ingress Controller (AGIC)**: Historically, AGIC was not supported with CNI Overlay, requiring workarounds. This is now in public preview.
*   **Unsupported Configurations**:
    *   Virtual Machine Availability Sets (VMAS) are not supported.
    *   DCsv2-series virtual machines are not supported in node pools.
*   **Network Security Groups (NSGs)**: Pod-to-pod traffic is not encapsulated, so subnet NSG rules are applied. You must ensure rules are in place to allow traffic between the node and pod CIDRs for proper cluster function.
*   **Naming Conventions**: If using a custom subnet, the names of the subnet, VNet, and its resource group must be 63 characters or less to comply with Kubernetes label syntax rules.


### AKS and DNS Zones: Public vs. Private Resolution

When creating an Azure Kubernetes Service (AKS) cluster, especially a private one, DNS plays a critical role in how the Kubernetes API server is accessed. The API server is the heart of the cluster, and both internal components (like nodes) and external users (like developers using `kubectl`) need to resolve its address.

#### The Core Purpose of DNS Zones in AKS

The primary purpose of DNS zones with AKS is to provide a reliable way to resolve the Fully Qualified Domain Name (FQDN) of the API server to its IP address.

*   **For a Public Cluster**: The API server gets a public IP address, and a corresponding A record is created in Azure's public DNS servers. This is straightforward and works out-of-the-box.
*   **For a Private Cluster**: The API server gets a private IP address from your virtual network (VNet). [5] This IP is not accessible from the public internet. Therefore, a mechanism is needed to resolve the API server's FQDN to this private IP. This is where Azure Private DNS Zones come in. [1, 5]

---

### How DNS Zones are Created and Used

When you provision a **private AKS cluster**, you have a few choices for how DNS is handled. [2]

#### 1. System-Managed Private DNS Zone (Default)

*   **What happens?**: If you don't specify otherwise, AKS automatically creates a new Azure Private DNS Zone for you. [2]
*   **Location**: This zone is created within the node resource group (the `MC_...` resource group). [2]
*   **Function**: It automatically creates an 'A' record that maps the API server's FQDN to its private IP address. [11]
*   **VNet Link**: Crucially, AKS links this private DNS zone to the VNet where the cluster nodes reside. [2] This link is what allows any resource within that VNet (or peered VNets) to resolve the FQDN correctly. [6]
*   **Use Case**: This is the simplest option for getting a private cluster up and running without manual DNS configuration. [1]

#### 2. Using an Existing (Custom) Private DNS Zone

*   **What happens?**: In enterprise environments, you often have a centrally managed DNS infrastructure (a "hub-spoke" model). [10] You can instruct AKS to register its API server in a private DNS zone that you have already created.
*   **Requirements**:
    *   The Private DNS Zone must be named in a specific format, typically `privatelink.<region>.azmk8s.io`. [2]
    *   The AKS cluster's managed identity needs "Private DNS Zone Contributor" and "Network Contributor" permissions on the zone and VNet respectively to be able to create the 'A' record. [10]
*   **Use Case**: Ideal for organizations that need to centralize DNS management and integrate with existing DNS servers. [1]

#### 3. No Private DNS Zone (`--private-dns-zone none`)

*   **What happens?**: When you select this option, AKS does **not** create a Private DNS Zone. [2] Instead, it creates an A record in Azure's **public** DNS.
*   **Key Detail**: Even though the DNS record is public, it resolves to the **private IP address** of the API server's private endpoint. [9]
*   **Function**: This means anyone on the internet can find the private IP of your API server, but they still cannot connect to it unless they have a network path to your VNet (e.g., via a VPN, ExpressRoute, or a jumpbox VM). [7]
*   **Use Case**: This can simplify scenarios where you don't want to manage Private DNS Zones but still require the API server to be on a private IP. [1]

---

### Public vs. Private DNS Resolution: The Key Differences

| Feature                 | Public DNS Resolution for AKS                                     | Private DNS Resolution for AKS                                       |
| ----------------------- | ----------------------------------------------------------------- | -------------------------------------------------------------------- |
| **Zone Type**           | Uses Azure's global, public DNS infrastructure.                   | Uses an Azure Private DNS Zone, scoped to one or more VNets. [5]     |
| **Record Visibility**   | The FQDN and its IP address are resolvable by anyone on the internet. | The FQDN and its IP address are only resolvable by resources within linked VNets. [2] |
| **AKS API Server IP**   | Can resolve to a public IP (for public clusters) or a private IP (with the `none` option). [9] | Always resolves to a private IP address within your VNet. [11]       |
| **Primary Use Case**    | Default for public AKS clusters. An option for private clusters to avoid managing private zones. | The standard and most secure method for private AKS clusters. [5] Ensures the API server endpoint is not publicly discoverable. |
| **Connectivity**        | Resolves the name, but connectivity still depends on network firewalls and having a public vs. private IP. | Resolves the name for clients inside the VNet, enabling direct and secure communication over the private network. [6] |
