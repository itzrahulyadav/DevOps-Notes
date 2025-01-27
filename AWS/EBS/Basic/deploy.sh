#!/bin/bash

echo "deploying to cloudformation"

STACK_NAME="ec2-stack4"
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
--parameter-overrides InstanceType=t2.micro

# command to update the stack
aws cloudformation update-stack \
--stack-name ec2-stack4 \
--parameters ParameterKey=InstanceType,ParameterValue=t2.micro \
--template-body file://template.yaml

