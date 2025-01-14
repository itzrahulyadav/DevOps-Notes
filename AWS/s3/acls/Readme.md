# Create a new bucket

``` sh

aws s3api --region ap-south-1 create-bucket --bucket multiverse-bucket-123 --create-bucket-configuration LocationConstraint=ap-south-1

```


# Block public access

```sh

 aws s3api put-public-access-block \
    --bucket multiverse-bucket-123 \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=true,RestrictPublicBuckets=true"

```

# Get public access block

```sh
 aws s3api get-public-access-block --bucket multiverse-bucket-123

```

## change bucket ownership 

```sh

aws s3api put-bucket-ownership-controls \
    --bucket multiverse-bucket-123 \
    --ownership-controls="Rules=[{ObjectOwnership=BucketOwnerPreferred}]"

```


## Enable ACLs

```sh
aws s3api put-bucket-acl --bucket multiverse-bucket-123 --access-control-policy file:///workspace/DevOps-Notes/AWS/s3/acls/policy.json
```