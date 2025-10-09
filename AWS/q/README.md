# Generate IT inventory

```
Create an IT inventory report for server resources in the AWS us-east-1 region. The report should contain:
* Resource type
* Instance type
* vCPU
* Memory (GB)
* Public IP
* Private IP
* OS
* Open port(s)
* IAM role
* Comments - based on AWS best practice
Summarize the information in to table. which each instance in the same row.
Output the report in markdown format save as inventory.md

```

# Create a dashboard

```
Create a CloudWatch monitoring dashboard using AWS best practices for the following workload
CloudFormation name: sample-app
Region: us-east-1
Before creating the dashboard, try querying the metrics first to ensure they exist, then create the dashboard

```

# Check vpc flow logs

```
What is the top 50 traffic going through NAT Gateway ENI in the last 1 hour
VPC name: sampleapp-VPC
Region: us-east-1
Query traffic from VPC flow log
Make sure to check log format to see the field
Output to traffic_table.csv




Download the full list of AWS IP ranges from https://ip-ranges.amazonaws.com/ip-ranges.json
then create a filtered list of AWS IP addresses.
* Exclude "service": "AMAZON"
* Filter IP for region: us-east-1
Output to filtered_aws_ips.csv



Tag IPs in traffic_table.csv using filtered_aws_ips.csv to understand what each IP is associated with
* VPC IP
* AWS Service Name
* Internet
Output as CSV traffic_tagged.csv



Using traffic_tagged.csv, create a network visualization diagram. 
Node is IP address, with label IP, Tag. 
Edge is a directed graph between src address and dst address 
Edge weight based on total data transfer volume, edge thickness proportional to data transfer volume. Use graphviz library to visualize.


Can you group IPs with the same tag closer together


```

# 3.0 - Advance networking analysis

```

Create a new log group and VPC flow log for VPC name 'sampleapp-VPC' in us-east-1
Capture at 1-minute intervals and store it in CloudWatch logs.
Use a log format that allows logs to see traffic going through the NAT gateway, as well as which AWS service. 
Output the flow log details and VPC CIDR to a markdown file custom-flowlog.md


tail the vpc flowlog 

```

# 3.1 - Network visualization

```

What is the top 20 traffic by byte transfer
Focus on pkt-srcaddr, pkt-dstaddr, pkt-src-aws-service, pkt-dst-aws-service
Ignore srcaddr, dstaddr
Query traffic from VPC flow log details in custom-flowlog.md
Make sure to check log format to see the fields
Output to traffic_table.csv




Using traffic_table.csv, create a network visualization diagram. 
Node is IP address, with label as IP
Label:
* VPC
* AWS services (Service name: S3, DynamoDB, etc.)
* Internet
Edge is a directed graph between pkt-srcaddr and pkt-dstaddr
Edge weight based on total data transfer volume
Use networkx and graphviz to visualize.


```


### SSM Automation

```
Create an automation using AWS Systems Manager 
To schedule EC2 instances with names containing 'sampleapp-load-generator' in us-east-1 
The EC2 instances should be running on weekdays, 9-to-5 Bangkok time, and stopped during other time slots
```
