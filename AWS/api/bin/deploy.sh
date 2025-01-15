#!/bin/bash 

aws cloudformation deploy \
--template-file ../template.yaml \
--stack-name my-example-stack \
--region ap-south-1 \
--capabilities CAPABILITY_IAM
