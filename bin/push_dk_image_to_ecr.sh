#!/bin/bash

# push docker image to ECR

# arguments:
# $1 == aws account id
# $2 == aws region
# $3 == ecr repo name

# authenticate into ECR:
# https://docs.aws.amazon.com/cli/latest/reference/ecr/get-login-password.html
# not suitable for production environments!!

echo "=== Authenticating to ECR ==="
echo $(aws ecr get-login-password --region $2 | docker login --username AWS --password-stdin $1.dkr.ecr.$2.amazonaws.com)

echo "=== Pushing image ==="
echo $(docker push $1.dkr.ecr.$2.amazonaws.com/$3)

echo "=== Image pushed ==="
