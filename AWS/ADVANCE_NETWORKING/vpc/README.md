

# ENI
- It's a logical component in vpc that represents virtual network card 
-  enables ip address and allow network communication
-  bound to specific AZs
-  Has a mac address
-  has a source/destination check flag
-  Secondary ENI can be attached to any ec2 instances


# Requester Managed ENI

Requester Managed Network Interfaces (ENIs) in AWS
- Created and managed by AWS services (e.g. ELB, RDS, Lambda)
- Cannot be detached/deleted by users directly 
- Automatically deleted when the associated service is terminated
- Have predefined security group rules based on service requirements
- Examples:
  - ELB creates ENIs to handle traffic distribution
  - RDS creates ENIs for DB instance connectivity
  - Lambda creates ENIs for VPC access 
  - ECS tasks use ENIs for container networking
- Identified by "requester-managed" flag in AWS console
- Cannot modify most ENI attributes except tags
- Security groups can only be modified through service configuration
- IP addresses are auto-assigned from VPC subnet



# Amazon DNS server - Amazon Route 53 resolver

- VPC comes with default DNS server also known as Route 53 resolver endpoint
- Runs at VPC base + 2 address and can also be accessed at virtual ip 169.254.169.253
- Resolves DNS requests from (in the same order mentioned):
   - Route 53 private hosted zone
   - VPC internal DNS (AWS maanaged DNS names)
   - Forwards other requests to public DNS including Route 53 public hosted zone




# VPC DHCP Option Sets

DHCP (Dynamic Host Configuration Protocol) option sets in AWS VPC allow you to:
- Configure DNS settings for EC2 instances in your VPC
- Control how instances resolve DNS names and locate domain controllers

Key attributes that can be configured:
- domain-name-servers: List of DNS servers (max 4)
- domain-name: DNS domain name for your instances  
- ntp-servers: List of NTP servers (max 4)
- netbios-name-servers: List of NetBIOS name servers (max 4)
- netbios-node-type: NetBIOS node type (1, 2, 4 or 8)

Important notes:
- DHCP options are immutable - cannot be modified after creation
- Only one DHCP option set can be associated with a VPC at a time
- Default VPC DHCP options include:
  - Amazon DNS server (AmazonProvidedDNS)
  - Domain name based on region (e.g. ec2.internal for us-east-1)
- Custom DHCP options override the default options
- Changes take effect on instance restart or DHCP lease renewal

Common use cases:
- Use custom DNS servers instead of Amazon DNS
- Add domain suffix search lists
- Configure Active Directory integration
- Set up custom NTP servers for time synchronization 

- To refresh the DHCP option parameters use the following command:

```
$sudo dhclient -r eth0

```


# Inbound Resolver Endpoints
- Allow DNS queries from on-premises networks to resolve AWS resources
- Must create ENIs in your VPC to receive DNS queries
- Requires 2 or more IP addresses in different AZs for high availability
- On-premises DNS servers forward queries to the inbound endpoint IP addresses
- Supports conditional forwarding rules based on domain names

# Outbound Resolver Endpoints  
- Enable DNS resolution from VPC to on-premises DNS servers
- Must create ENIs in your VPC to forward DNS queries
- Requires 2 or more IP addresses in different AZs for high availability
- Forward rules determine which DNS queries are sent to on-premises resolvers
- Can specify target IP addresses of on-premises DNS servers

# Key Features
- Highly available with multi-AZ deployment
- Security groups control access to endpoints
- Support for hybrid DNS resolution between AWS and on-premises
- Integrated with AWS RAM for sharing between accounts
- Pay per ENI-hour and per billion DNS queries

# Common Use Cases
- Resolve on-premises domain names from AWS resources
- Access AWS private hosted zones from on-premises networks  
- Hybrid DNS resolution for applications spanning cloud and datacenter
- Centralized DNS management in complex network architectures

# Configuration Steps
- Create resolver endpoints in VPC
- Configure security groups to allow DNS traffic
- Set up forwarding rules for domain names
- Update on-premises DNS servers to use endpoints
- Test DNS resolution in both directions