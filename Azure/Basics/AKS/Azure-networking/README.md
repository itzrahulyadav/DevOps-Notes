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




### ExternalDNS for Kubernetes

ExternalDNS is a Kubernetes tool that automates the management of DNS records for your cluster's services in external DNS providers. [1, 10] It acts as a controller, watching for changes in your Kubernetes resources and synchronizing them with your DNS provider, such as Azure DNS, AWS Route 53, or Google Cloud DNS. [1, 8]

#### The Problem It Solves

When you expose an application to the internet using a Kubernetes `Service` of type `LoadBalancer` or an `Ingress`, Kubernetes assigns it a public IP address or a hostname. [15] Manually creating and updating DNS records to point your domain to this IP/hostname is tedious, error-prone, and doesn't scale. If the IP address changes, your service goes down until you manually update the DNS record. [15]

ExternalDNS solves this by automating the entire process. [12]

#### How It Works

1.  **Deployment**: ExternalDNS runs as a `Deployment` inside your Kubernetes cluster. [3]
2.  **Watching Resources**: It watches the Kubernetes API for specific resources, primarily `Services` and `Ingresses`. [1, 4]
3.  **Detecting Changes**: When it detects a new `Service` or `Ingress` that needs a DNS record, it reads its configuration.
4.  **Using Annotations**: You tell ExternalDNS which hostname to create by adding a specific annotation to your resource's metadata, such as `external-dns.alpha.kubernetes.io/hostname: "app.example.com"`. [3, 11]
5.  **API Calls to DNS Provider**: It extracts the external IP address (from a `LoadBalancer` Service) or the Ingress controller's IP/hostname. [15] It then uses the credentials you've configured to make API calls to your external DNS provider (e.g., Azure DNS) to create or update the corresponding DNS record (usually an `A` or `CNAME` record). [3]
6.  **Continuous Synchronization**: ExternalDNS runs in a control loop. [1] If you delete the `Ingress` or `Service`, it will automatically delete the corresponding DNS record, keeping your DNS configuration clean and synchronized with the state of your cluster. [12]

#### Key Use Cases

*   **Ingress Hostnames**: When you define a `host` in an Ingress rule (e.g., `host: myapp.example.com`), ExternalDNS automatically creates a DNS record for `myapp.example.com` pointing to the Ingress controller's load balancer. [15]
*   **LoadBalancer Services**: For a `Service` of type `LoadBalancer`, you can add an annotation to create a DNS record pointing directly to the public IP assigned to that service. [7, 11]

#### Benefits of Using ExternalDNS

*   **Automation**: Eliminates the need for manual DNS management, reducing the risk of human error and saving time. [5, 12]
*   **Dynamic Updates**: DNS records are automatically updated when IP addresses change, improving service reliability. [7]
*   **Provider Agnostic**: It supports a wide rang



### CoreDNS in Azure Kubernetes Service (AKS)

CoreDNS is the default, built-in DNS server for all modern AKS clusters. [1, 5] It is a critical component that runs as a set of pods in the `kube-system` namespace and handles all DNS resolution and service discovery within the cluster. [5, 7]

---

#### What is CoreDNS?

*   **A DNS Server**: At its core, CoreDNS is a flexible and extensible DNS server. It replaced the older `kube-dns` as the Kubernetes standard. [4]
*   **CNCF Project**: Like Kubernetes itself, CoreDNS is a graduated project of the Cloud Native Computing Foundation (CNCF). [2]
*   **Plugin-Driven**: Its functionality is built on a chain of plugins. [4, 6] This modular architecture allows it to be highly customizable for various networking scenarios. [6]

---

#### What is it Used For in AKS?

CoreDNS has two primary responsibilities within an AKS cluster:

1.  **Cluster Service Discovery (Internal DNS)**:
    *   This is its main job. When one pod needs to communicate with another service (e.g., a backend API), it uses the service's DNS name (e.g., `my-backend.default.svc.cluster.local`). [3]
    *   CoreDNS intercepts this query and resolves the service name to its internal ClusterIP address, enabling seamless communication between pods. [3, 4]
    *   It dynamically updates its records as pods and services are created, scaled, or removed. [3]

2.  **External Name Resolution**:
    *   When a pod needs to connect to an external resource (e.g., `google.com` or an Azure SQL database), CoreDNS handles that too. [3]
    *   If the query is not for a service within the cluster, CoreDNS forwards the request to an upstream DNS server. [3]
    *   By default in AKS, this "upstream server" is the same DNS service that the AKS nodes themselves use, which is typically Azure DNS. [8]

---

#### How to Install and Manage CoreDNS

*   **Installation**: You don't need to install it. CoreDNS is an essential add-on managed by AKS and is enabled by default in every cluster. [1] It is automatically deployed and scaled for high availability (usually as two pods). [7]

*   **Management & Customization**:
    *   While AKS manages the CoreDNS deployment, you can customize its behavior.
    *   You **cannot** directly edit the main CoreDNS configuration file (`Corefile`). [1]
    *   Instead, you create a Kubernetes `ConfigMap` named `coredns-custom` in the `kube-system` namespace. [1, 9]
    *   CoreDNS is configured to automatically load and merge the settings from this custom ConfigMap with its default configuration. [9]

*   **Applying Customizations**:
    1.  Create a YAML file for your `coredns-custom` ConfigMap.
    2.  Define custom behaviors using CoreDNS plugins. A common use case is using the `forward` plugin to send DNS queries for a specific custom domain to an on-premises DNS server. [9]
    3.  Apply the ConfigMap using `kubectl apply -f your-configmap.yaml`. [1]
    4.  To make the changes take effect without downtime, perform a rolling restart of the CoreDNS pods: `kubectl -n kube-system rollout restart deployment coredns`. [1, 8]

This approach allows you to extend CoreDNS functionality for advanced scenarios like split-horizon DNS, DNS rewrites, or integrating with private DNS zones, while AKS continues to manage the lifecycle of the CoreDNS pods themselves. 




### Kubernetes Gateway API: The Evolution of Ingress

The Gateway API is an open-source project managed by the Kubernetes community. [1] It is the next-generation, official evolution of the Kubernetes Ingress API, designed to address the limitations of Ingress and provide a more expressive, role-oriented, and extensible model for managing traffic routing into a cluster. [1, 2]

---

#### The Problem with Ingress

While functional, the standard Ingress API has several limitations that became apparent as Kubernetes matured:

*   **Role Ambiguity**: A single `Ingress` object mixes infrastructure concerns (like which load balancer to use) with application routing rules. This creates conflicts between cluster operators and application developers.
*   **Lack of Standardization**: Features like traffic splitting, header manipulation, and different routing strategies are not standard. They are implemented using custom annotations, which are different for every Ingress controller (e.g., NGINX vs. Traefik annotations). [5]
*   **Limited Expressiveness**: It struggles to model more complex routing scenarios beyond simple host/path-based routing.

---

### The Gateway API: A Role-Oriented Approach

The Gateway API solves these problems by splitting the single Ingress object into multiple, role-oriented resources. [3] This creates a clear separation of concerns between different personas managing the cluster. [2]

#### The Three Core Components (Personas)

1.  **`GatewayClass` (Managed by the Infrastructure Provider)**
    *   **What it is**: A cluster-scoped template that defines a *type* of load balancer available to the cluster. [4] It references a specific controller that will manage Gateways of this class.
    *   **Persona**: **Infrastructure Provider** (e.g., the cloud provider like Azure, or the team that manages cluster infrastructure).
    *   **Analogy**: It's like defining the *models* of cars available for purchase (e.g., "Standard Sedan," "Luxury SUV"). In Azure, there would be a `GatewayClass` for Application Gateway for Containers.

2.  **`Gateway` (Managed by the Cluster Operator)**
    *   **What it is**: A request for a specific load balancer to be provisioned. It's a namespaced resource that selects a `GatewayClass` and defines the listeners (e.g., "listen for HTTPS traffic on port 443 on host `store.example.com`"). [4]
    *   **Persona**: **Cluster Operator** or **Platform Administrator**. This person manages the shared infrastructure for multiple application teams.
    *   **Analogy**: The operator *chooses* a car model (`GatewayClass`) and requests a specific instance of it, defining its entry points (the doors and windows of the load balancer).

3.  **`Route` Resources (Managed by the Application Developer)**
    *   **What they are**: These resources define the application-level routing rules. They attach to a `Gateway` to specify how traffic arriving at a listener should be handled. [3] The most common type is `HTTPRoute`.
    *   **Persona**: **Application Developer**. This person knows their application's services and how traffic should be routed between them.
    *   **Analogy**: The developer defines the *directions* for where passengers (traffic) should go once they enter the car (the `Gateway`). For example: "If the URL path is `/login`, send them to the `auth-service`."
    *   **Types of Routes**: The API is extensible and includes different route types for different protocols, such as:
        *   `HTTPRoute`: For HTTP/HTTPS traffic (path/header/query param routing, traffic splitting). [1]
        *   `TCPRoute`: For Layer 4 TCP traffic.
        *   `UDPRoute`: For Layer 4 UDP traffic.
        *   `TLSRoute`: For TLS Passthrough.

#### How They Work Together (The Workflow)

`Infrastructure Provider` -> `Cluster Operator` -> `Application Developer`

1.  The **Provider** installs the controller and makes a `GatewayClass` available (e.g., `azure-application-gateway`).
2.  The **Operator** creates a `Gateway` resource, selecting that class and defining a listener for `*.example.com` in the `infra-ns` namespace.
3.  The **Developer** creates an `HTTPRoute` in their `app-ns` namespace that attaches to the `Gateway` in `infra-ns` and routes traffic for `myapp.example.com/api` to their `api-service`.

This model is secure and decoupled. Developers can only attach routes to Gateways that operators have explicitly allowed them to, and they cannot change fundamental infrastructure settings like ports or TLS certificates on the Gateway itself.

---

### Application Gateway for Containers (AGC)

**Application Gateway for Containers (AGC)** is Azure's official, managed implementation of the Gateway API. [6, 7] It is the successor to the Application Gateway Ingress Controller (AGIC).

#### How AGC Implements the Gateway API

AGC uses a split-architecture model that combines the best of Kubernetes and Azure:

1.  **Control Plane (Inside Kubernetes)**: When you enable the AGC addon in AKS, it installs a controller inside your cluster. [6] This controller's job is to watch the Kubernetes API for `GatewayClass`, `Gateway`, and `HTTPRoute` resources. [7]

2.  **Data Plane (The Azure Application Gateway)**: The controller translates the state of your Gateway API resources into the specific configuration required by an **Azure Application Gateway v2 SKU**. [7] It then uses the Azure Resource Manager (ARM) API to program the data plane.

This means:
*   You manage your traffic routing using standard, portable Kubernetes YAML files (`HTTPRoute`).
*   The actual work of load balancing, TLS termination, and applying Web Application Firewall (WAF) policies is handled by the robust, high-performance, and managed Azure Application Gateway PaaS service, not by pods running on your cluster nodes. [7]

#### Benefits of Using AGC

*   **Managed Performance & Security**: Leverages the battle-tested Azure Application Gateway for the heavy lifting, providing features like WAF, autoscaling, and global distribution that are difficult to replicate with in-cluster controllers. [7]
*   **Role-Oriented and Safe**: Fully embraces the secure, multi-tenant model of the Gateway API.
*   **Advanced Traffic Management**: Supports expressive Gateway API features like traffic splitting (for canary releases), header-based routing, and more, all configured via standard Kubernetes objects.
*   **Official Azure Support**: As the premier Azure implementation, it is fully supported and integrated with AKS.

In short, AGC allows you to use the modern, flexible Kubernetes Gateway API as your configuration front-end, while using a powerful, managed Azure service as the traffic-handling back-end.
