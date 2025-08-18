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




# Notes on Outbound Traffic in Azure Kubernetes Service (AKS)

## Introduction to Egress (Outbound) Traffic in AKS

Egress, or outbound traffic, refers to network traffic originating from within an AKS cluster and destined for external services. By default, an AKS cluster has unrestricted outbound internet access. [4] However, for security, governance, and specific network architecture requirements, it is often necessary to control and manage this egress traffic. AKS provides several outbound types to configure how your cluster sends traffic to the outside world. [10]

The primary outbound types available in AKS are:
*   **Load Balancer**
*   **NAT Gateway**
*   **User-Defined Routing (UDR)**

Understanding these is crucial for designing a secure and efficient networking model for your AKS cluster.

---

## Outbound Type: Load Balancer

This is the default outbound type for an AKS cluster. [3] When you create a cluster without specifying an outbound type, AKS automatically provisions a public, Standard SKU Azure Load Balancer. [1, 10]

### How it Works

*   AKS associates a public IP address with the Load Balancer for egress traffic. [1]
*   All outbound traffic from the nodes in the cluster is source-NAT'd (SNAT) using this public IP. [8]
*   The Load Balancer translates the private IP addresses of the nodes to its public IP address for outbound connections. [13]

### Potential Issues

*   **SNAT Port Exhaustion**: A single public IP address has a limited number of available ports for SNAT. If your applications make a high number of outbound connections, you can run out of available ports, leading to connection failures. [2, 3] This can be mitigated by allocating more public IPs to the load balancer's outbound pool. [2]

### Ingress with Load Balancer Egress

*   When you create a Kubernetes service of type `LoadBalancer` or deploy an ingress controller, the same Azure Load Balancer created for egress can be used for ingress. [3]
*   For ingress, a new public IP address is typically provisioned and attached to the frontend of the load balancer. [2]
*   This means you can have one public IP for all outbound traffic and one or more separate public IPs for inbound traffic for your various services. [2]

---

## Outbound Type: NAT Gateway

Using a NAT Gateway is a more scalable and resilient way to handle outbound traffic from your AKS cluster, especially for workloads with a high number of outbound connections. [3] AKS can either manage the NAT Gateway for you (`managedNatGateway`) or you can use a pre-existing one (`userAssignedNatGateway`). [10]

### How it Works

*   When you configure your AKS cluster with the NAT Gateway outbound type, outbound traffic from the cluster's subnet is directed to the Azure NAT Gateway. [1]
*   The NAT Gateway handles the SNAT, translating the private IPs of the nodes to the public IP address(es) associated with the gateway.
*   A key advantage is that a NAT Gateway can be associated with multiple public IP addresses or a public IP prefix, providing up to 64,000 SNAT ports per IP address, significantly reducing the risk of SNAT port exhaustion. [2, 11]

### Ingress with NAT Gateway Egress

*   When using a NAT Gateway for egress, no Load Balancer is created by default for outbound traffic. [2]
*   However, if you expose a service of type `LoadBalancer` or deploy an ingress controller, AKS will still provision a Standard Load Balancer to handle the **inbound** traffic for that service. [2]
*   This Load Balancer will have its own public IP for ingress, and the inbound traffic will be directed to the appropriate pods.
*   The key distinction is that the outbound traffic from the pods will still egress through the NAT Gateway, not the Load Balancer used for ingress.

---

## Outbound Type: User-Defined Routing (UDR)

The `userDefinedRouting` outbound type offers the most control over your egress traffic and is often used in hub-spoke network architectures or when you need to route outbound traffic through a network virtual appliance (NVA) like Azure Firewall. [2, 5]

### How it Works

*   With this setup, AKS does not automatically configure egress paths. You are responsible for setting up the egress route. [1, 9]
*   You must deploy your AKS cluster into an existing virtual network with a subnet that you have pre-configured. [9]
*   A Route Table is associated with the AKS subnet. This route table contains a User-Defined Route (UDR) that directs outbound traffic (typically for the address prefix `0.0.0.0/0`) to the private IP address of your NVA (e.g., Azure Firewall). [2]
*   The NVA then handles the traffic according to its configured rules, performs NAT using its own public IP, and forwards the traffic to the internet. [3] This allows for fine-grained filtering and logging of outbound traffic. [7]

### Ingress with UDR Egress

*   With the UDR outbound type, a public load balancer is **not** created by default. [5]
*   However, similar to the NAT Gateway scenario, if you create a Kubernetes service of type `LoadBalancer`, AKS will provision a Standard Load Balancer with a public IP for **inbound** requests. [9, 15]
*   The crucial point here is that while ingress traffic comes through this load balancer, the return traffic will follow the UDR and egress through the NVA (e.g., Azure Firewall). [3]
*   **Asymmetric Routing**: This can lead to a situation known as asymmetric routing, where the response traffic takes a different path than the request traffic. Some network appliances might drop this traffic. To mitigate this, you can:
    *   Also route the ingress traffic through the NVA's public IP and use DNAT rules to forward it to the internal load balancer. [3]
    *   Use an Application Gateway Ingress Controller (AGIC), where the Application Gateway receives the ingress traffic and routes it directly to the pods using their private IPs. The return traffic then correctly goes back through the Application Gateway. [2]
 



# AKS Cluster with HTTP Proxy

In environments where outbound internet access must be routed through an HTTP proxy, you can configure an AKS cluster to use this proxy for its egress traffic. This ensures that both the AKS nodes and the pods running on them send their outbound traffic through the designated proxy. 

---

## Creating an AKS Cluster with HTTP Proxy using a JSON file

To create an AKS cluster with HTTP proxy settings, you first define the proxy configuration in a JSON file. This file is then referenced during the cluster creation process using the Azure CLI. [1]

### JSON Configuration File Structure

The JSON file should contain the following properties:

*   `httpProxy`: The URL of the HTTP proxy for creating HTTP connections outside the cluster. The scheme must be `http`. [9]
*   `httpsProxy`: The URL of the HTTPS proxy. If this is not specified, the `httpProxy` value will be used for both HTTP and HTTPS connections. [9]
*   `noProxy`: An array of strings specifying destination domain names, domains, IP addresses, and CIDR blocks that should bypass the proxy. [1, 9]
*   `trustedCa`: A Base64-encoded string of an alternative CA certificate to be installed on the nodes. This is only necessary if your proxy uses a custom certificate. [2, 9]

**Example `aks-proxy-config.json`:**
```json
{
  "httpProxy": "http://my-proxy.example.com:8080",
  "httpssProxy": "https://my-proxy.example.com:8443",
  "noProxy": [
    "localhost",
    "127.0.0.1",
    ".svc",
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
    ".internal.contoso.com"
  ],
  "trustedCa": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCkJBTkNlcnRpZmljYXRlRGF0YVB1dEhlcmUKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
}
Azure CLI Command for Cluster Creation
Once the JSON file is created, you can use the az aks create command with the --http-proxy-config parameter to create the cluster. [1, 3]
code
Bash
az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --http-proxy-config aks-proxy-config.json
You can also apply this configuration to an existing cluster using az aks update. [4] Note that when updating proxy settings, your pods must be restarted to pick up the new environment variables. For node-level components like containerd, a node image upgrade is required for the changes to take effect. [3, 4]
How Environment Variables are Injected into Pods
When an AKS cluster is configured with an HTTP proxy, a mutating admission webhook automatically injects the proxy settings as environment variables into the pods as they are created. [2]
The following environment variables are injected into each pod (in both uppercase and lowercase): [1, 2]
HTTP_PROXY and http_proxy
HTTPS_PROXY and https_proxy
NO_PROXY and no_proxy
Most client libraries and applications automatically recognize and use these environment variables to route their outbound traffic through the specified proxy. You can verify that these variables have been injected by running kubectl describe pod <pod-name>. [2]
Making Exceptions and Bypassing the Proxy
There are two primary ways to make exceptions and prevent traffic from going through the proxy:
1. Using the noProxy Configuration
The noProxy list in your JSON configuration is the standard way to define endpoints that should be reached directly, bypassing the proxy. [1, 5] This is ideal for:
Internal services within your virtual network.
Communication with other Azure services.
Any endpoint that does not require or should not go through the proxy.
AKS automatically adds necessary internal endpoints to the noProxy list to ensure the cluster functions correctly. [8]
2. Disabling Proxy Variable Injection for a Specific Pod
If you have a specific application or pod that should not use the proxy settings at all, you can prevent the injection of the proxy environment variables by adding an annotation to the pod's metadata. [2, 4]
By adding the annotation "kubernetes.azure.com/no-http-proxy-vars": "true", the mutating webhook will skip that pod, and no proxy environment variables will be set. [1, 10]
Example Pod Manifest with Proxy Exception:
code
Yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-no-proxy
  annotations:
    "kubernetes.azure.com/no-http-proxy-vars": "true"
spec:
  containers:
  - name: nginx
    image: nginx
```

# Notes on Controlling Outbound Traffic with Network Policies in AKS

By default, all pods in an Azure Kubernetes Service (AKS) cluster can send and receive traffic without limitations. To improve security, you can apply the principle of least privilege by defining rules that control traffic flow. Network policies are a Kubernetes feature that defines access policies for communication between pods.

AKS supports different network policy engines, with Calico and Cilium being two powerful options for controlling outbound (egress) traffic.

---

## Creating an AKS Cluster with a Network Policy Plugin

To use network policies, you must enable a network policy engine when creating the AKS cluster. This cannot be changed after the cluster is created.

### Creating a Cluster with Calico

You can enable Calico with either Azure CNI or kubenet network plugins. Use the `--network-policy calico` flag during cluster creation.

**Example Azure CLI command:**

```bash
az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --network-plugin azure \
    --network-policy calico

```

## Cilium



```
az aks create \
    --resource-group myResourceGroup \
    --name myCiliumAKSCluster \
    --network-plugin azure \
    --network-dataplane cilium
```



# AKS egress static gateway

# AKS Static Egress Gateway

An Azure Kubernetes Service (AKS) Static Egress Gateway provides a stable and predictable outbound public IP address for traffic originating from your AKS cluster. This is achieved by routing the egress (outbound) traffic from specified pods through a dedicated set of nodes known as the gateway node pool.

### How it Works

Normally, when pods in an AKS cluster initiate outbound traffic to the internet, the source IP address can be one of the public IPs of the AKS load balancer or a random IP from the agent node's virtual machine scale set. This dynamic IP allocation can be problematic when you need to interact with external services that require IP address whitelisting for security purposes.

The Static Egress Gateway addresses this by allowing you to designate a specific node pool to handle egress traffic. This gateway node pool is assigned a static public IP prefix. By annotating your application's pods, you can direct their outbound traffic to flow through this dedicated node pool, ensuring that all external services see the traffic as coming from the known, static IP address(es) of the gateway.

### Common Use Cases

The primary use cases for an AKS Static Egress Gateway revolve around security and predictable network identity:

* **IP Whitelisting for External Services:** Many external services, such as databases, APIs, and other corporate resources, restrict access based on the source IP address. A static egress gateway ensures that your AKS workloads have a consistent IP address that can be added to the allowlists of these services.

* **Enhanced Security Posture:** By channeling outbound traffic through a single, controlled point, you can apply more granular network security policies and monitoring. This simplifies auditing and helps in identifying the source of outbound connections.

* **Consistent Identity:** For applications that require a consistent identity when interacting with external systems, a static egress IP provides a reliable way to establish that identity without the complexities of managing individual pod IPs.

* **Simplified Firewall Rules:** When communicating with on-premises data centers or other VNet-peered environments, having a known, static IP for your cluster's egress traffic simplifies the configuration of firewall rules on the destination side.

### Benefits of Using a Static Egress Gateway

Employing a Static Egress Gateway in your AKS cluster offers several advantages:

* **Improved Security:** It allows for stricter control over which pods can communicate with external services and provides a clear audit trail for outbound traffic.
* **Simplified Integration:** It streamlines the integration of your AKS applications with external systems that rely on IP-based security.
* **Predictable Networking:** It removes the uncertainty of dynamic outbound IP addresses, leading to more stable and reliable communication with external endpoints.
* **Granular Control:** You can selectively route traffic from specific applications or namespaces through the egress gateway, while other workloads can continue to use the default egress path.

In essence, the AKS Static Egress Gateway is a valuable feature for organizations that require a higher level of control and security for their outbound cluster traffic, particularly when interacting with IP-restricted external resources.


### Preserving Client IP in AKS with `externalTrafficPolicy`

When you expose a service in AKS using a `type: LoadBalancer`, the client's original source IP address is often lost. The network packets get source NAT'd (Network Address Translation) as they move through the cluster's nodes. This means your application sees the IP of the Kubernetes node that routed the traffic, not the actual end-user's IP.

You can preserve the original client IP by setting the `externalTrafficPolicy` field in your Service manifest to `Local`.

---

### How `externalTrafficPolicy` Works

This field in the Kubernetes Service specification defines how to route external traffic to your pods. It has two possible values:

* **`Cluster` (Default):**
    * Traffic that hits the external load balancer is forwarded to *any* node in the cluster.
    * The node then uses `kube-proxy` rules to route the traffic to a pod running the service, even if that pod is on a *different* node.
    * **Pro:** Distributes traffic evenly across all available pods in the cluster.
    * **Con:** Obscures the client source IP because of the extra network hop and the resulting SNAT. Your application logs will show an internal cluster IP as the source.

* **`Local`:**
    * Traffic from the external load balancer is routed **only** to nodes that are currently running at least one of the service's pods.
    * It avoids the second hop within the cluster. The packet goes directly from the load balancer to a pod on the same node.
    * **Pro:** **Preserves the client's source IP address.** Since there's no extra hop between nodes, the source IP on the incoming packet is not changed.
    * **Con:** Can lead to uneven traffic distribution. If one node has three pods for a service and another has only one, the node with one pod will still receive a proportional amount of traffic, potentially overloading that single pod. The load isn't spread across *all* pods, only across the nodes that have pods.

---

### Example Service Manifest

To implement this, you simply add `externalTrafficPolicy: Local` to your Service's `spec`.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  type: LoadBalancer
  # This is the key field to preserve the client IP
  externalTrafficPolicy: Local
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

## Installing pods in specific nodepools

It can be achived using **Kyverno**

The controller intercepts pod creation requests, reads a label from the pod's namespace, and then adds the correct `nodeSelector` to the pod before it's created. This enforces scheduling rules at a namespace level.

Here are the notes on how to set it up using Kyverno.

***

### 🏷️ Schedule Pods via Namespace Labels

This method uses a policy engine to automatically assign pods to specific nodepools based on a label applied to their namespace.

The overall workflow is:
1.  **Label Nodepools:** Assign a unique label to each target nodepool (e.g., `pool=gpu-pool`).
2.  **Label Namespaces:** Assign a label to a namespace indicating which nodepool it should target (e.g., `target-pool=gpu-pool`).
3.  **Apply Kyverno Policy:** A cluster-wide policy will watch for new pods. When a pod is created, the policy reads the `target-pool` label from the pod's namespace and injects a `nodeSelector` into the pod's definition, forcing it onto the correct nodepool.

---

### ⚙️ Example Implementation with Kyverno

Let's say you have a nodepool for GPU-intensive applications and another for general-purpose tasks.

#### Step 1: Label Your Nodepools

First, ensure your AKS nodepools have distinct labels. You can add or update labels using the Azure CLI.

```bash
# Add a label to your GPU nodepool
az aks nodepool update \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name gpunp \
    --labels 'pool=gpu-pool'

# Add a label to your general-purpose nodepool
az aks nodepool update \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name generalnp \
    --labels 'pool=general-pool'
```

label the namespaces 

```
# Label the 'ml-apps' namespace to target the GPU pool
kubectl label namespace ml-apps target-pool=gpu-pool --overwrite

# Label the 'web-apps' namespace to target the general pool
kubectl label namespace web-apps target-pool=general-pool --overwrite

```


Install kyverno

```
# Example for a recent version, check Kyverno's docs for the latest install command
kubectl create -f [https://github.com/kyverno/kyverno/releases/download/v1.12.3/install.yaml](https://github.com/kyverno/kyverno/releases/download/v1.12.3/install.yaml)

```

Create a cluster policy in kyverno

```
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: sync-nodeselector-from-namespace
spec:
  rules:
  - name: add-nodeselector-from-namespace
    match:
      any:
      - resources:
          kinds:
          - Pod
    # Use context to fetch the 'target-pool' label from the pod's namespace
    context:
    - name: nodepool_label
      apiCall:
        urlPath: "/api/v1/namespaces/{{request.namespace}}"
        jmesPath: "metadata.labels.\"target-pool\" || ''"
    # Mutate (modify) the pod being created
    mutate:
      patchStrategicMerge:
        spec:
          # Add a nodeSelector if the namespace label exists
          # The '+' character makes it a conditional anchor
          +(nodeSelector):
            # The value is taken from the context variable defined above
            pool: "{{nodepool_label}}"

```
