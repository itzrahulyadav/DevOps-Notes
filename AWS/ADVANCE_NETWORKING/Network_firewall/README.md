
# AWS Network Firewall Notes

# 1. Overview
# - Managed network firewall service for VPCs
# - Provides stateful inspection and filtering of network traffic
# - Centrally manage firewall rules across multiple VPCs and accounts

# 2. Key Features
# - Stateful traffic filtering
# - Protocol detection and blocking
# - Domain name filtering
# - IP/Port based filtering 
# - Regex pattern matching
# - TLS inspection
# - Alert and flow logging

# 3. Components
# - Firewall - Main resource that contains rules and policies
# - Firewall Policy - Collection of rule groups and default actions
# - Rule Groups - Reusable sets of rules for traffic filtering
# - Endpoints - VPC subnet locations where firewall inspects traffic

# 4. Rule Types
# - Stateful rules
#   - 5-tuple rules (protocol, source IP, dest IP, source port, dest port)
#   - Domain list rules
#   - Suricata compatible rules
# - Stateless rules
#   - Basic packet filtering based on protocol, ports, IPs

# 5. Logging Options
# - Flow logs - Captured traffic metadata
# - Alert logs - Rule match events
# - Logs sent to CloudWatch Logs or S3

# 6. Key Benefits
# - Consistent security across VPCs
# - Managed service - no infrastructure to maintain
# - Integration with AWS services
# - Scalable and highly available
# - Detailed traffic visibility

# 7. Use Cases
# - Filter outbound traffic to internet
# - Protect workloads from malicious traffic
# - Block access to unwanted domains
# - Monitor network traffic patterns
# - Implement security compliance requirements



# Network Firewall Components

## Firewall
- Primary resource that contains rules and policies
- Manages traffic inspection and filtering
- Can be associated with multiple VPCs

## Firewall Policy 
- Collection of rule groups and default actions
- Defines how traffic should be handled
- Contains ordered list of rule groups
- Specifies default actions for unmatched traffic

## Rule Groups
- Reusable sets of rules for traffic filtering
- Can be shared across multiple firewall policies
- Contains stateful and/or stateless rules
- Supports rule priorities and ordering


## Stateful Rule Groups

### Overview
- Maintain state information about traffic flows
- Track connections and sessions
- More sophisticated traffic analysis
- Higher processing overhead

### Rule Types
- 5-tuple rules
  - Protocol
  - Source IP
  - Destination IP 
  - Source port
  - Destination port
- Domain list rules
  - Allow/deny traffic to specific domains
  - DNS filtering
- Suricata compatible rules
  - IDS/IPS style rules
  - Pattern matching
  - Protocol analysis

### Key Features
- Deep packet inspection
- Protocol awareness
- Session tracking
- Application layer filtering
- Regular expression matching

## Stateless Rule Groups

### Overview
- Basic packet filtering
- No state tracking
- Lower processing overhead
- Simpler rule evaluation

### Rule Types
- Protocol rules
- Port rules
- IP address rules
- CIDR block rules

### Key Features
- Fast packet processing
- Simple allow/deny rules
- No connection tracking
- Basic header inspection
- Bidirectional rule matching

## Rule Group Limits
- Maximum of 10,000 rules per stateful rule group
- Maximum of 10,000 rules per stateless rule group 
- Up to 100 rule groups per firewall policy
- Rule capacity measured in rule units

## Endpoints
- VPC subnet locations where firewall inspects traffic 
- Must be deployed in dedicated firewall subnets
- Requires one endpoint per Availability Zone
- Handles traffic inspection and filtering at subnet level
