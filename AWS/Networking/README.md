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
