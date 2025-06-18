

aws cloudformation deploy \
--template-file ./cloudformation.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--no-execute-changeset \
--stack-name triple-vpcs \
--region ap-south-1