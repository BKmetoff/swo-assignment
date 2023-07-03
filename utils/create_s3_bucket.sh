#!bin/bash

# This script creates an S3 bucket
# used to store the terraform state.

# arguments
# $1 == bucket name
# $2 == aws region

aws s3api create-bucket\
   --bucket $1-tf-state \
   --region $2 \
   --create-bucket-configuration LocationConstraint=$2