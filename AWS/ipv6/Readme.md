# Create a vpc

```
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --amazon-provided-ipv6-cidr-block
```

# Create a subnet
```
aws ec2 create-subnet --vpc-id vpc-082cd0c44d4d21c1e --ipv6-cidr-block 2406:da1a:a0e:d700::/64 --cidr-block 10.0.0.0/24
```

# Enable DNS support

```sh
aws ec2 modify-subnet-attribute --subnet-id <Your wish> --enable-dns64

```

# Create an egress only internet gateway

```
aws ec2 create-egress-only-internet-gateway --vpc-id <vpc_ID>
```

# Create internet gateway

```
aws ec2 create-internet-gateway

```

# attach internet gateway to vpc
```
aws ec2 attach-internet-gateway --internet-gateway-id <igw> --vpc-id <vpc>

```

# Create an elastic ip

```
aws ec2 allocate-address
```

# Create nat gateway

```sh
aws ec2 create-nat-gateway --subnet-id <you thought I will leave it here> --allocation-id <ip_allocation_id>

```

# Create a route table

```sh
aws ec2 create-route-table --vpc-id vpc-082cd0c44d4d21c1e

```

# Create an entry in route table

```sh
aws ec2 create-route --route-table-id rtb-******** --destination-ipv6-cidr-block ::/0 --egress-only-internet-gateway-id eigw-********

```

# Create route for nat gateway ipv6 to ipv4 translation
```sh 
aws ec2 create-route --route-table-id rtb-06cb701b755e79c5a --destination-ipv6-cidr-block 64:ff9b::/96 --nat-gateway-id <nat id>
```

# Create a route for ipv4 address

```sh
aws ec2 create-route --route-table-id rtb-xxxxxxx --destination-cidr-block 0.0.0.0/0 --gateway-id igw-xxxxxxxxxxx
