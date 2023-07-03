# create tf state bucket with env vars

# This script manages the full provisioning of the infrastructure
# and the deployment of the web application.

# The full flow takes about 15 minutes to complete.
# The AWS region is provided as a default value in /variables.tf.

# arguments:
# $1 == DB password

# Example usage
# ./bin/entrypoint db_password
# Note: the PW has to be 8 chars minimum

if [ $# -eq 0 ]; then
    >&2 echo "No DB password provided. See Readme.md for more information"
    exit 1
fi

echo "=== Setting environment variables ===\n"
export ECR_REPO_NAME=swo-assignment
export AWS_REGION=eu-west-1
export AWS_ACCOUNT_ID=$(
  aws sts get-caller-identity --output json |
    tr -d '",' |
    grep 'Account' |
    awk '{print $2}'
  )

echo "=== Provisioning VPC, ECR, RDS ===\n"
terraform apply \
  -target module.vpc \
  -target module.ecr \
  -target module.rds \
  -var db_password="$1" \
  -auto-approve

sleep 5


# NOTE!
# The docker image needed for Fargate
# needs to be built using amd64 architecture!
# See Dockerfile for more details.
echo "==== Building Docker image ====\n"
./bin/build_dk_image.sh $AWS_ACCOUNT_ID $AWS_REGION $ECR_REPO_NAME

echo "==== Pushing Docker image to ECR ====\n"
./bin/push_dk_image_to_ecr.sh $AWS_ACCOUNT_ID $AWS_REGION $ECR_REPO_NAME

sleep 5

# To run the web app in ECS,
# it's necessary to have
# an initialized DB, a ECR image
# and an EFS volume.
# Therefore, ECS, EFS, EC2
# are provisioned at this stage.
echo "==== Provisioning ECS, EFS, EC2 ====\n"
terraform apply \
  -target module.efs \
  -target module.ecs \
  -target module.ec2_bastion \
  -var db_password="$1" \
  -auto-approve

echo "==== Provisioning complete! ====\n"
echo "==== Load balancer URL: ===="
terraform output load_balancer_address

