# 
# Autonomous System Numbers (ASN) Notes:

# - ASNs are unique identifiers assigned to autonomous systems (networks) on the internet
# - Originally 16-bit numbers (1-65535), now also 32-bit (1-4294967295) 
# - ASNs 64512-65534 are reserved for private use
# - ASNs 0, 54272-64511, and 65535 are reserved by IANA
# - Used in BGP routing to identify networks and their routing policies
# - Managed globally by IANA and regionally by RIRs (ARIN, RIPE, APNIC, etc)
# - Format examples:
#   - 16-bit: AS1234
#   - 32-bit: AS65536
# - Required for networks that want to:
#   - Participate in BGP routing
#   - Connect to multiple ISPs
#   - Manage their own routing policies
# - Can be looked up in public databases like WHOIS


# Border Gateway Protocol (BGP) Notes:
#
# - BGP is the routing protocol that makes the internet work
# - Current version is BGP-4 (RFC 4271)
# - Key characteristics:
#   - Path vector protocol
#   - Uses TCP port 179 for reliable transport
#   - Maintains connections with neighbor routers (peers)
#   - Exchanges network reachability information
#   - Makes routing decisions based on paths, rules and policies
#
# BGP Message Types:
# - OPEN: Establishes BGP session between peers
# - UPDATE: Advertises or withdraws routes
# - KEEPALIVE: Maintains connection
# - NOTIFICATION: Reports errors and closes connection
#
# BGP Attributes:
# - AS_PATH: List of ASNs that the route has traversed
# - NEXT_HOP: IP address of next router in path
# - LOCAL_PREF: Local preference value for route selection
# - MED: Multi-exit discriminator for multiple paths
#
# BGP Route Selection Process:
# 1. Highest LOCAL_PREF
# 2. Shortest AS_PATH length
# 3. Lowest MED value
# 4. eBGP over iBGP
# 5. Lowest IGP metric to NEXT_HOP
# 6. Lowest BGP router ID
#
# Types of BGP Sessions:
# - iBGP: Internal BGP (within same AS)
# - eBGP: External BGP (between different ASs)
#
# Best Practices:
# - Filter routes with access lists
# - Use route maps for policy control
# - Implement route aggregation
# - Monitor BGP session states
# - Secure BGP sessions with authentication