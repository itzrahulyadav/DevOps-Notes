### AWS GuardDuty

- Intelligent threat detection system
- Uses Machine learning algorithms
- uses
    - vpc flow logs
    - DNS logs
    - Cloud trail event logs
- Can protect againts crypto currency attacks
- Can manage multiple accounts
- Findings are potential security issues for malicious events happening in aws account
- Automated response can be sent using eventbridge
- Alerts can be send to lambda,sns,slack etc.
- Findings can be suppressed and archieved , it is not mandatory to send it to security hub,s3 or eventbridge.
- DNS logs only work if default VPC DNS resolver is used.
- Learn more about it [here](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html)

### AWS Security Hub

- Central security tool to manage security across several AWS accounts and automate security checks.
- Integrated dashboards to show current security and compliance status to quickly take actions.
- AWS config must be enabled.
- It collect potential findings and issues which can generate eventbridge event,can perform automated checks and can be investigated using amazon detective.
#### Main features
- cross region aggregation
- AWS organization integration
- By default organization management account is the security hub admin but we can also designate security hub administator from members account.
- Guardduty is automatically enabled when security hub is enabled , Guardduty will send findings to security hub.
- 3rd party tools like 3corssec,aqua etc. can also send findings to security hub.
- Also supports custom actions to send events to eventbridge.
- Learn more about it [here](https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html)

### Amazon Detective

- Analyzes,investigates and quickly identifies the root cause of security issues or suspecious activities. (using ML and Graph)
- Collects events from vpc flow logs,cloudtrail , guardduty and creates unified view.


NOTE: DDOS simulation testing can be done on AWS resources adhering to a few rules 

### EC2 Key pairs

- The public key is stored in ec2 ebs volume in the ~/.ssh/authorized_keys location and the private key gets downloaded into the users system.
- In case ec2 instance gets compromised delete all the keys from ~/.ssh/authorized_keys location and then upload the new keys.
- This process can be automated using ssm run command.

### Handling lost ec2 ssh key pairs

- use user data script using cloud-config format(which will run on every reboot) and attach the new public key in the commands section,once the instance restarts we can connect cause we have new private key with us.
- we can run ssm document called awssupport-Resetaccess automation document, it will create new key pair and store the private key in parameter store (ec2rl/openssh/instance_id/key) and store the public key inside ec2 for us to connect
- Use instance connect ,store new key in ~/.ssh/authorized_keys .
- Use ec2 serial console and store the new key,just like instance connect
- Detach the ebs volume, create a new instance and attach the ebs volume of previous one,now the new key pair will also get stored in the ebs volume. Detach it and attach it to the previous ec2 instance.

### Rescue tools for ec2
- rescue tools can be used on ec2 instances and store the logs in ec2.
- can be run using ssm documents.

### AWS AUP
- https://aws.amazon.com/aup/

### Amazon Inspector
- Performs automated security accessment
- Leverages ssm agent and use it on ec2
- Analyzes running os against known vulnerabilities
- Accessment of container images when they are pushed to ecr
- Identifies function code and package vulnerabilites
- access of lambda function when they are deployed.
- Can be integrated with Security Hub
- Sends findings to eventbridge

### Logging
- Read [this whitepaper](https://aws.amazon.com/blogs/security/new-whitepaper-security-at-scale-logging-in-aws/)
- Service logs are available in aws:
  - cloudtrail logs
  - AWS config
  - AWS cloudwatch
  - vpc flowlogs
  - ELB logs
  - cloudfront logs
  - WAF logs
- All the above logs can be stored in s3 bucket and can be queried using athena.


### AWS cloudwatch unified agent
- Agent that can be installed in EC2 instances.
- Collect additional metrics like RAM utilization,process and disk space
- Send logs to cloudwatch logs
- Can be managed using SSM parameter store
- Sends logs to namespace called CWAgent(can be configured/changed)

   ## - procstat_plugin
   - can be used to collect metrics of individual processes
   - supports both windows and linux servers


### IAM
- We can leverage notAction and deny policies which server the different purpose
- We can use different conditional operators:
    - StringEquals/StringNotEquals - case sensitive/exact matching
    - Stringlike/StringNotlike - case sensitive/optional matching is allowed like *
    - DateEquals/DateLessThan - use to compare dates
    - ArnLike/ArnNotLike - used for ARNs
    - Bool - used for boolean values
    - IpAddress/NotIPAddress(CIDR)
 
- IAM conditions
    - Requested region
    - PrincipalArn
    - Arnlike(SourceArn)
    - CalledVia (only supports dynamodb,athena,cloudformation,kms)
    - IP & VPC conditions
    - aws:Sourcelp 
       - Public requester IP (e.g., public EC2 IP if coming from EC2) • Not present in requests through VPC Endpoints
       - aws:VpcSourcelp - requester IP through VPC Endpoints (private IP)
       - aws:SourceVpce - restrict access to a specific VPC Endpoint
       - aws:SourceVpc • Restrict to a specific VPC ID • Request must be made through a VPC Endpoint 
       - Common to use these conditions with S3 Bucket Policies
    - Multi factor authentication present
    - aws:PrincipalOrgID
    - ResourceTag & PrincipalTag
    ```
    example:
     "ec2:ResourceTag/Project": "Dataanalytics"
      "aws:PrincipalTag/Department": "Data"
    ```
    - 
