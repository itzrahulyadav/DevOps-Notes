# IOPS
IOPS stands for Input/Output Operations Per Second. It is a performance measurement used in computing, particularly in the context of storage systems, to evaluate how many read or write operations a system can handle in one second.

# Throughput

Throughput is a measure of how much data can be successfully transferred from one place to another in a given amount of time. It is commonly used in networking, storage, and computing to evaluate the performance of systems and infrastructure.

```
Throughput = Total Data Transferred / Time Taken

Throughput = 1 GB / 10 s = 100 MB/s

```

# Bandwidth

Bandwidth refers to the maximum amount of data that can be transmitted over a network or communication channel in a given amount of time. It is a critical metric in networking and telecommunications and is typically expressed in units of bits per second (e.g., Mbps, Gbps).

 


# Amazon Elastic Block Store (EBS)

Amazon Elastic Block Store (EBS) is a scalable, high-performance block storage service designed for use with Amazon Elastic Compute Cloud (EC2) for both throughput and transaction-intensive workloads.

## Key Features

- **Persistent Storage**: EBS volumes are persistent, meaning data is retained even after the associated EC2 instance is stopped or terminated.
- **Scalability**: Easily scale your storage up or down as needed.
- **High Availability**: EBS volumes are automatically replicated within their Availability Zone to protect against hardware failures.
- **Snapshots**: Create point-in-time snapshots of EBS volumes, which are stored in Amazon S3. Snapshots can be used to create new EBS volumes.
- **Encryption**: EBS supports encryption of data at rest, in transit, and all volume backups.

## Types of EBS Volumes

1. **General Purpose SSD (gp2/gp3)**: Balanced price and performance for a wide variety of workloads.
2. **Provisioned IOPS SSD (io1/io2)**: Designed for I/O-intensive applications such as large databases.
3. **Throughput Optimized HDD (st1)**: Low-cost HDD volume designed for frequently accessed, throughput-intensive workloads.
4. **Cold HDD (sc1)**: Lowest cost HDD volume designed for less frequently accessed workloads.

## Use Cases

- **Database Storage**: Suitable for relational and NoSQL databases.
- **File Systems**: Ideal for file storage and sharing.
- **Big Data Analytics**: Supports large-scale data processing applications.
- **Backup and Restore**: Efficiently create backups and restore data.

## Best Practices

- **Regular Snapshots**: Regularly take snapshots of your EBS volumes to ensure data durability.
- **Monitor Performance**: Use Amazon CloudWatch to monitor the performance and status of your EBS volumes.
- **Optimize Costs**: Choose the appropriate volume type based on your workload requirements to optimize costs.

## Pricing

EBS pricing is based on the following factors:
- Volume type and size
- Provisioned IOPS (for io1/io2 volumes)
- Data transfer
- Snapshot storage

For detailed pricing information, refer to the [Amazon EBS Pricing](https://aws.amazon.com/ebs/pricing/) page.

## Additional Resources

- [Amazon EBS Documentation](https://docs.aws.amazon.com/ebs/)
- [Amazon EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)


# AWS EBS Volume Types and Usage Notes

---

## General Purpose SSD Volumes
- **Volume Types**: `gp2`, `gp3`
- **Use Cases**:
  - General workloads.
  - Transactional workloads.
  - Virtual desktops.
  - Medium-sized, single-instance databases.
  - Low-latency interactive applications.
  - Boot volumes.
  - Development and test environments.
- **Durability**: 99.8%–99.9%
- **Volume Size**: 1 GiB – 16 TiB
- **Maximum IOPS**:
  - `gp2`: 16,000 IOPS (16 KiB I/O size)
  - `gp3`: 16,000 IOPS (16 KiB I/O size)
- **Maximum Throughput**:
  - `gp2`: 250 MiB/s
  - `gp3`: 1,000 MiB/s
- **Features**:
  - **EBS Multi-Attach**: Not Supported
  - **NVMe Reservation**: Not Supported
  - **Boot Volume**: Supported

---

## Provisioned IOPS SSD Volumes
- **Volume Types**: `io1`, `io2`, `io2 Block Express`
- **Use Cases**:
  - Workloads requiring sustained IOPS performance or more than 16,000 IOPS.
  - I/O-intensive database workloads.
  - `io2 Block Express`: Designed for sub-millisecond latency and sustained performance.
- **Durability**:
  - `io1`, `io2`: 99.8%–99.9%
  - `io2 Block Express`: 99.999%
- **Volume Size**:
  - `io1`, `io2`: 4 GiB – 16 TiB
  - `io2 Block Express`: 4 GiB – 64 TiB
- **Maximum IOPS**:
  - `io1`: 64,000 IOPS (16 KiB I/O size)
  - `io2`: 64,000 IOPS (16 KiB I/O size)
  - `io2 Block Express`: 256,000 IOPS (16 KiB I/O size)
- **Maximum Throughput**:
  - `io1`, `io2`: 1,000 MiB/s
  - `io2 Block Express`: 4,000 MiB/s
- **Features**:
  - **EBS Multi-Attach**:
    - `io1` and `io2`: Supported
    - `io2 Block Express`: Supported
  - **NVMe Reservation**: Supported
  - **Boot Volume**: Supported


# AWS EBS Volume Type Usage Notes

---

## General Purpose SSD Volumes
### `gp2`
- **Use Case**: 
  - Most general workloads.
  - Transactional workloads.
  - Virtual desktops.
  - Medium-sized, single-instance databases.
  - Low-latency interactive applications.
  - Boot volumes.
  - Development and test environments.
- **Durability**: 99.8% - 99.9%.
- **Volume Size**: 1 GiB – 16 TiB.
- **Max IOPS**: 16,000 (16 KiB I/O).
- **Max Throughput**: 250 MiB/s.
- **Features**:
  - **EBS Multi-Attach**: Not Supported.
  - **NVMe Reservation**: Not Supported.
  - **Boot Volume**: Supported.

### `gp3`
- **Use Case**:
  - Same as `gp2` (general workloads, databases, etc.).
- **Durability**: 99.8% - 99.9%.
- **Volume Size**: 1 GiB – 16 TiB.
- **Max IOPS**: 16,000 (16 KiB I/O).
- **Max Throughput**: 1,000 MiB/s.
- **Features**:
  - **EBS Multi-Attach**: Not Supported.
  - **NVMe Reservation**: Not Supported.
  - **Boot Volume**: Supported.

---

## Provisioned IOPS SSD Volumes
### `io1`
- **Use Case**:
  - Workloads requiring sustained IOPS performance or more than 16,000 IOPS.
  - I/O-intensive database workloads.
- **Durability**: 99.8% - 99.9%.
- **Volume Size**: 4 GiB – 16 TiB.
- **Max IOPS**: 64,000 (16 KiB I/O).
- **Max Throughput**: 1,000 MiB/s.
- **Features**:
  - **EBS Multi-Attach**: Supported.
  - **NVMe Reservation**: Supported.
  - **Boot Volume**: Supported.

### `io2`
- **Use Case**:
  - Same as `io1`.
- **Durability**: 99.8% - 99.9%.
- **Volume Size**: 4 GiB – 16 TiB.
- **Max IOPS**: 64,000 (16 KiB I/O).
- **Max Throughput**: 1,000 MiB/s.
- **Features**:
  - **EBS Multi-Attach**: Supported.
  - **NVMe Reservation**: Supported.
  - **Boot Volume**: Supported.

### `io2 Block Express`
- **Use Case**:
  - Sub-millisecond latency.
  - Sustained IOPS performance.
  - More than 64,000 IOPS or 1,000 MiB/s throughput.
- **Durability**: 99.999%.
- **Volume Size**: 4 GiB – 64 TiB.
- **Max IOPS**: 256,000 (16 KiB I/O).
- **Max Throughput**: 4,000 MiB/s.
- **Features**:
  - **EBS Multi-Attach**: Supported.
  - **NVMe Reservation**: Supported.
  - **Boot Volume**: Supported.
