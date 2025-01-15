# Get subnets

```
aws ec2 describe-subnets --region ap-south-1 --query Subnets[].AvailabilityZones

```

## use filters
```
aws ec2 describe-subnets --region ap-south-1 --filter Name=availability-zone,Values=ap-south-1a,ap-south-1b --query=Subnets[].

```