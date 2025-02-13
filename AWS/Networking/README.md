### AWS Direct connect (DX):

- Dedicated network connection from on-premise to AWS
- Uses aws direct connect location to connect AWS with on-premise datacenters
- Provide latency and low bandwidth
- Low data transfer cost
- can access AWS private network and vpc endpoints like s3,DynamoDB.
- The traffic does not go to internet because of dedicated (cable/wire) based connection.
- Uses DX locations for connection which are owned by Third party providers
- Needs 4-12 weeks for setup and provides speed of 1,10,100 GBPS

#### Direct connect requirements:
- Single node fiber
- 802.iq vlan encapsulation must be supported
- auto negotiation of port must be disabled
- Customer router must support BGP
- BFD (Bidirectional forwarding detection) must be enabled

#### AWS VPC DNS Server (Route 53 Resolver endpoint)

- AWS VPC comes with default DNS server called route 53 DNS resolver
- Runs at vpc base + 2 base address (if vpc is 10.0.0.0) then vpc dns server will run at 10.0.0.2(can also be accessed from 169.254.169.253)
- It resolves requests from:
     - Route 53 dns hosted zone
     - vpc internal DNS (Will send all the public queries to public DNS servers like ec2 private dns and others)
     - forwards other requests to route 53 public hosted zone (including vpc internet endpoints)
- Accessible only from vpc (visual paradox)

#### DHCP option set 

- DHCP tells the resources where to go for DNS queries
- The options field of a Dynamic Host Configuration Protocol message contains the configuration parameters like domain name, domain name server, NTP server and the NetBIOS node type
- AWS automatically creates and associates a DHCP option set for your VPC upon creation and sets following parameters: • domain-name-servers: This defaults to Amazon Provided DNS • domain-name: This defaults to the internal Amazon domain name for your region (e.g <ip>.ap-south-1.compute.internal)


#### Route 53 resolver dns firewall
- With Route 53 Resolver DNS Firewall, you can filter and regulate outbound DNS traffic for your virtual private cloud (VPC). To do this, you create reusable collections of filtering rules in DNS Firewall rule groups, associate the rule groups to your VPC, and then monitor activity in DNS Firewall logs and metrics. Based on the activity, you can adjust the behavior of DNS Firewall accordingly.
- full docs [here](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall.html)

#### Ipsec tunnel

#### DNS64 and NAT64


#### AWS Network firwall
- Stateful managed firewall
- It utilizes suricata IDS/IPS open source software
- Full doc [here](https://docs.aws.amazon.com/network-firewall/latest/developerguide/what-is-aws-network-firewall.html)

### Transit Gateway

```mermaid
graph TD
    TG[Transit Gateway]
    
    VPC1[VPC 1]
    VPC2[VPC 2]
    VPC3[VPC 3]
    VPC4[VPC 4]

    NAT[NAT Gateway]
    
    IGW[Internet Gateway]

    TG -- Attachments --> VPC1
    TG -- Attachments --> VPC2
    TG -- Attachments --> VPC3
    TG -- Attachments --> VPC4

    VPC1 -- Route --> NAT
    VPC2 -- Route --> NAT
    VPC3 -- Route --> NAT
    VPC4 -- Route --> NAT
    
    NAT -- Route --> IGW

    IGW -- Internet Traffic --> VPC1
    IGW -- Internet Traffic --> VPC2
    IGW -- Internet Traffic --> VPC3
    IGW -- Internet Traffic --> VPC4
```
