#!/bin/bash

VPC_ID=$(aws ec2 create-vpc --cidr-block "10.0.0.0/16" \
--tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=AutoBot}]' \
--region ap-south-1 \
--query Vpc.VpcId \
--output text)

echo $VPC_ID