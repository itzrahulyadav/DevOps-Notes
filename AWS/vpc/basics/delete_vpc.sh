#!/bin/bash

if [ -z "$1" ]; then
    echo "No arguments provided. Please provide an argument."
    exit 1
else
    export VPC_ID="$1"
fi

aws ec2 delete-vpc --vpc-id $VPC_ID --region ap-south-1
