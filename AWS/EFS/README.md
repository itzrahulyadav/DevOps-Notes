# AWS EFS (Elastic File System)

## Overview
Amazon Elastic File System (EFS) is a scalable, fully managed elastic NFS file system for use with AWS Cloud services and on-premises resources. It is designed to be highly available and durable.

It uses NFSV4.1 protocol
EC2 should install NFSV4.1 client to use EFS


## Key Features
- **Scalability**: Automatically scales your file system storage up or down as you add or remove files.
- **Performance Modes**: Offers two performance modes, General Purpose and Max I/O, to optimize for different workloads.
- **Storage Classes**: Provides Standard and Infrequent Access storage classes to optimize costs.
- **Security**: Supports encryption of data at rest and in transit, and integrates with AWS IAM for access control.

## Use Cases
- **Content Management**: Ideal for content repositories, development environments, and media workflows.
- **Big Data and Analytics**: Suitable for big data applications that require high throughput and IOPS.
- **Backup and Restore**: Can be used for backup, restore, and disaster recovery solutions.

## Getting Started
1. **Create an EFS File System**: Use the AWS Management Console, CLI, or SDKs to create a new file system.
2. **Mount the File System**: Mount the EFS file system to your EC2 instances or on-premises servers.
3. **Manage and Monitor**: Use CloudWatch to monitor performance and set up alarms for your file system.

## Pricing
EFS pricing is based on the amount of data stored, the storage class used, and the amount of data transferred. Refer to the [AWS EFS Pricing](https://aws.amazon.com/efs/pricing/) page for detailed information.

## Resources
- [AWS EFS Documentation](https://docs.aws.amazon.com/efs/)
- [AWS EFS FAQs](https://aws.amazon.com/efs/faqs/)
- [AWS EFS Best Practices](https://docs.aws.amazon.com/efs/latest/ug/best-practices.html)


## EFS Client (amazon-efs-utils)

The EFS client, also known as `amazon-efs-utils`, is a collection of Amazon EFS tools. It simplifies the process of mounting and managing EFS file systems on your EC2 instances.

### Installation
To install the EFS client on an Amazon Linux or Amazon Linux 2 instance, use the following commands:
```bash
sudo yum install -y amazon-efs-utils
```

For Ubuntu, use:
```bash
sudo apt-get install -y amazon-efs-utils
```

### Features
- **Mount Helper**: Simplifies the process of mounting EFS file systems.
- **TLS Support**: Provides support for mounting file systems with encryption in transit using TLS.
- **IAM Authorization**: Supports IAM authorization for EFS.

### Usage
To mount an EFS file system using the EFS client, use the following command:
```bash
sudo mount -t efs -o tls file-system-id efs-mount-point
```

Refer to the [amazon-efs-utils GitHub repository](https://github.com/aws/efs-utils) for more details and advanced usage.
