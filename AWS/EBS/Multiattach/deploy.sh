#!/bin/bash

echo "deploying to cloudformation"

STACK_NAME="EBS-Multiattach"
root_path=$(realpath .)
template_path="./template.yaml"
parameters="ParameterKey=InstanceType,ParameterValue=t2.micro"

# command to deploy the stack
aws cloudformation deploy \
--template-file $template_path \
--capabilities CAPABILITY_NAMED_IAM \
--no-execute-changeset \
--stack-name $STACK_NAME \
--region ap-south-1 \
# --parameter-overrides InstanceType=t2.micro