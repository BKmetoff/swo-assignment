#!/bin/bash

# Use this script to force a re-deployment
# of the ECS service

# Arguments:
# $1 == aws region
# $2 == aws account id
# $3 == cluster name
# $4 == service name

aws ecs update-service \
    --cluster arn:aws:ecs:$1:$2:cluster/$3 \
    --service arn:aws:ecs:$1:$2:service/$3/$4 \
    --force-new-deployment