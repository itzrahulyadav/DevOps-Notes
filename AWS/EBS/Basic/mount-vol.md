# check the volumes
`lsblk`

# Check the filesystems 
`sudo file -s /dev/xvdf`

# Attache the EBS volume


# Format the disk
`sudo mkfs -t xfs /dev/xvdb `

# Create a mountpoint 

`sudo mkdir -p /data `

# Mount the volume

`sudo mount /dev/xvdb /data `

# Check the mounting
` df -hT | grep /data `

