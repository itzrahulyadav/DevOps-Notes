#!/bin/bash

echo "deploying to cloudformation"

STACK_NAME="sns-basics"
root_path=$(realpath .)
template_path="${root_path}/template.yaml"

aws cloudformation deploy \
--template-file $template_path \
--capabilities CAPABILITY_NAMED_IAM \
--no-execute-changeset \
--stack-name $STACK_NAME \
--region ap-south-1