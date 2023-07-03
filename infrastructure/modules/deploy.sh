# These are to login and push docker images to ECR

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text | cut -f1)
export REGISTRY_URL=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REGISTRY_URL
docker --context dagster-ecs compose --project-name dagster up