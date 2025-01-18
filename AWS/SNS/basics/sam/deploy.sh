#!/bin/bash

sam deploy \
--template-file ../template.yaml \
--stack-name "lambdaandsns" \
--capabilities CAPABILITY_NAMED_IAM \
--region ap-south-1