#!/usr/bin/env bash

set -euo pipefail

PROFILE="${1}"
ENVIRONMENT="${2}"
ZIP_FILE="${3}"
S3_KEY_PREFIX="${4:-}"

CONFIG_FILE="deploy_config.yaml"

REGION="${AWS_REGION:-eu-west-2}"

# Validate inputs
if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Config file not found: ${CONFIG_FILE}"
    exit 1
fi

if [[ ! -f "${ZIP_FILE}" ]]; then
    echo "Zip file not found: ${ZIP_FILE}"
    exit 1
fi

LAMBDA_STACK=$(yq e ".environments.\"${ENVIRONMENT}\".lambda_stack" "${CONFIG_FILE}")
LAMBDA_BUCKET_NAME=$(yq e ".environments.\"${ENVIRONMENT}\".lambda_bucket_name" "${CONFIG_FILE}")

if [[ "${LAMBDA_STACK}" == "null" ]]; then
    echo "Unknown environment: ${ENVIRONMENT}"
    exit 1
fi

# Get filename and version from zip file
FILENAME=$(basename "${ZIP_FILE}")

VERSION=$(echo "${FILENAME}" | sed -E 's/.*-([0-9]+\.[0-9]+\.[0-9]+)\.zip/\1/')

if [[ "${VERSION}" == "${FILENAME}" ]]; then
    echo "Could not determine version from filename"
    echo "Expected: my-lambda-1.2.4.zip"
    exit 1
fi

echo "Checking AWS credentials..."

aws sts get-caller-identity \
    --profile "${PROFILE}" \
    --region "${REGION}" \
    >/dev/null

# Upload zip file to S3 and verify
S3_KEY="${S3_KEY_PREFIX}/${FILENAME}"
FILE_UPLOAD_LOCATION="s3://${LAMBDA_BUCKET_NAME}/${S3_KEY}"

echo
echo "Uploading:"
echo "$FILE_UPLOAD_LOCATION"
echo

aws s3 cp \
    "${ZIP_FILE}" \
    "${FILE_UPLOAD_LOCATION}" \
    --profile "${PROFILE}" \
    --region "${REGION}"

aws s3api head-object \
    --bucket "${LAMBDA_BUCKET_NAME}" \
    --key "${S3_KEY}" \
    --profile "${PROFILE}" \
    --region "${REGION}" >/dev/null

# Create change set for lambda stack
CHANGE_SET_NAME="lambda-$(date +%Y%m%d-%H%M%S)"

echo
echo "Creating change set..."
echo

# Get current parameters from the stack
PARAMETER_KEYS=$(aws cloudformation describe-stacks \
  --stack-name "${LAMBDA_STACK}" \
  --profile "${PROFILE}" \
  --query "Stacks[0].Parameters[].ParameterKey" \
  --output text)

# Build parameter list, keeping old parameters and updating the LambdaVersion parameter
PARAMETERS=()
for PARAMETER_KEY in $PARAMETER_KEYS
do
    if [[ "${PARAMETER_KEY}" == "LambdaVersion" ]]
    then
        PARAMETERS+=(
          "ParameterKey=${PARAMETER_KEY},ParameterValue=${VERSION}"
        )
    else
        PARAMETERS+=(
          "ParameterKey=${PARAMETER_KEY},UsePreviousValue=true"
        )
    fi
done

aws cloudformation create-change-set \
    --stack-name "${LAMBDA_STACK}" \
    --change-set-name "${CHANGE_SET_NAME}" \
    --change-set-type UPDATE \
    --use-previous-template \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters "${PARAMETERS[@]}" \
    --profile "${PROFILE}" \
    --region "${REGION}"

aws cloudformation wait change-set-create-complete \
    --stack-name "${LAMBDA_STACK}" \
    --change-set-name "${CHANGE_SET_NAME}" \
    --profile "${PROFILE}" \
    --region "${REGION}"

# Display planned changes for user confirmation
echo
echo "===================================================="
echo "ENVIRONMENT : ${ENVIRONMENT}"
echo "VERSION     : ${VERSION}"
echo "STACK       : ${LAMBDA_STACK}"
echo "BUCKET      : ${LAMBDA_BUCKET_NAME}"
echo "===================================================="

echo
echo "Planned changes:"
echo

aws cloudformation describe-change-set \
    --stack-name "${LAMBDA_STACK}" \
    --change-set-name "${CHANGE_SET_NAME}" \
    --query 'Changes[].ResourceChange.[Action,LogicalResourceId,ResourceType,Replacement]' \
    --output table \
    --profile "${PROFILE}" \
    --region "${REGION}"

echo
read -p "Execute change set? (y/N): " CONFIRM

if [[ ! "${CONFIRM}" =~ ^[Yy]$ ]]; then

    echo "Deleting change set..."

    aws cloudformation delete-change-set \
        --stack-name "${LAMBDA_STACK}" \
        --change-set-name "${CHANGE_SET_NAME}" \
        --profile "${PROFILE}" \
        --region "${REGION}"

    echo "Cancelled"

    exit 0
fi

# Execute change set
aws cloudformation execute-change-set \
    --stack-name "${LAMBDA_STACK}" \
    --change-set-name "${CHANGE_SET_NAME}" \
    --profile "${PROFILE}" \
    --region "${REGION}"

echo
echo "Waiting for deployment..."

aws cloudformation wait stack-update-complete \
    --stack-name "${LAMBDA_STACK}" \
    --profile "${PROFILE}" \
    --region "${REGION}"

echo "===================================================="
echo "Deployment complete"
echo "Environment : ${ENVIRONMENT}"
echo "Version     : ${VERSION}"
echo "===================================================="