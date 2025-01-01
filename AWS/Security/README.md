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

- ABAC (Attribute based access control)
   - Attribute-based access control (ABAC) is an authorization strategy that defines permissions based on attributes. AWS calls these attributes tags.
   - Eg. You can use a single policy that allows access when the IAM role and the AWS resource that have the same tag value.
   - Requires fewer policies
   - Scales permissions dynamically
   - Full [docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction_attribute-based-access-control.html)
 
- IAM credentials report can be used to get the details of the users IAM usage
- Aws config remediations can also be used.


  ### STS
  - Read about the confused deputy problem [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html)
  - External ID can be used to prevent confused deputy problem.
  - We can revoke the sessions of users who have used role in case the credentials are compromised [Read more] (https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_revoke-sessions.html)

  ### AWS IMDS
   - It gives information about ec2 instance (eg. Hostname,instance type ,networking )
   - Can be accessed using curl or wget - http://169.254.169.254/latest/meta-data
     
   - ```
        ami-id, block-device-mapping/, instance-id, instance-type, network/
      • hostname, local-hostname, local-ipv4, public-hostname, public-ipv4
      • lam - Instance ProfileArn, Instanceld
      • iam/security-credentials/role-name - temporary credentials for the role attached to your instance
      • placement/ - launch Region, launch AZ, placement group name...
      • security-groups - names of security groups
      • tags/instance - tags attached to the instance
     ```
 
   - Refer to this [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html)
 
  ### AWS s3

  - Access can provided using s3 bucket policies,IAM policies , SCP.
  - VPC inteface endpoint and VPC gateway endpoints can be used to access buckets within the VPC
  - AWS s3 access points/Global access points can be used to provide fine grained permissions.


  ### AWS Directory services

   ## Microsoft AD
    - Found on any windows server
    - It is a database of objects: user,accounts,computers,printers,security group
    - Objects are organized in trees
 
      
   ## AWS Directory services

   1. AWS managed microsoft AD
      - Create your own AD in aws,manage users locally
      - establish trust connection with your on-premise AD
   3. AD connector
      - Directory gateway to redirect to on-premises AD, supports MFA
      - Users are managed in on-premise AD
   3. Simple AD
      - can't be connected to on-premise AD
      - managed on AWS


  ### KMS
  - Read about asymmetric encryption [here](https://www.cloudflare.com/learning/ssl/what-is-asymmetric-encryption/)
  - AWS Kms multi-region key can be used in multi region
  -  Each set of related multi-Region keys has the same key material and key ID, so you can encrypt data in one AWS Region and decrypt it in a different AWS Region without re-encrypting or making a cross-Region call to AWS KMS.
  -  Read the [docs](https://docs.aws.amazon.com/kms/latest/developerguide/multi-region-keys-overview.html)

  ### Envelope encryption
  - Anything over 4KB of data that needs to encrypted must use envelope encryption which used generateDataKeyAPI
  - Link to the [topic](https://stackoverflow.com/questions/75445235/how-does-envelope-encryption-work-in-aws-kms)

  ### KMS Grant
  - Read [here](https://docs.aws.amazon.com/kms/latest/developerguide/grants.html)
  - We can use kms condition keys in IAM policies and key policies [doc](https://docs.aws.amazon.com/kms/latest/developerguide/conditions-kms.html)
  - Data key caching can be used to reduce latency,imporove throughput,reduce cost and number of API calls
 
### S3 Object encryption
- Objects in s3 can be encrypted using 4 methods
- SSE-S3 (enabled by default,encryptes objects using aws managed and owned keys)
- SSE-KMS (leverage AWS key management service to manage encryption keys)
- SSE-C (use our own encryption keys)
- Client side encryption

- S3 can leverage something called data key (called s3 bucket key) which can be used to reduce the api calls by 99%

  ### EC2 rescue tool for Linux
  - open source tool that helps to diagnose and troubleshoot common issues
  - Gather syslogs,diagnose problems
  - See the full documentation [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Linux-Server-EC2Rescue.html)
    
  ### AWS acceptable use policy
  - Governs your use of service offered by AWS
  - It can not be used for illegal or fraudant activity
  - Violate the rights of others
  - AWS abuse report [info](https://repost.aws/knowledge-center/report-aws-abuse)



  ### AWS Systems manager
  - AWS feature that allow us to handle multiple operations on a group of resources

    #### EC2 instance with ssm agent
    - Allows us to connect to ec2 instance without any ports or ssh keys
    - EC2 instance must have permissions and ssm agent must be insalled on the server

   #### Resource groups
    - Allow us to group resources on the basis of tags
    - Operations can be performed on all the resources present in the resource group
      
   #### SSM - Documents
    - Documents can be in json or YAML
    - you define parameters
    - you define actions
   #### SSM Run command
    - use to run commands/scripts in the ec2 servers/other resources

   #### SSM Automation
    - Allow us to perform operations on the fleet of ec2 instances
    - Used for performing operations like restarting ec2 instances etc.


   #### SSM parameter store


   #### SSM inventory
    - your managed instances and the software installed on them. It helps you gain insights into your environment by automatically gathering information about your systems, including their configuration, applications, and associated updates.
    - Works seamlessly with AWS Config, AWS Organizations, and AWS Resource Groups for enhanced governance and reporting.
 
   #### SSM state manager
    - Automates the process of keeping your managed instances in a consistent state. It helps you define, enforce, and monitor desired states for your instances, such as applying patches, installing software, configuring operating systems, and more.

   #### SSM Patch manager
    - automates the process of patching managed instances
    - os updates,security updates,app updates
  
