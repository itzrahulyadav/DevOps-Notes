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
