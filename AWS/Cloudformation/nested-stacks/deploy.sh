#!/bin/bash

echo "deploying to cloudformation"

STACK_NAME="nested-staxx"
root_path=$(realpath .)
template_path="./template.yaml"

aws cloudformation deploy \
--template-file stacks.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--no-execute-changeset \
--stack-name $STACK_NAME \
--region ap-south-1