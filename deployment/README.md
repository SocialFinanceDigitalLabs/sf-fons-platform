# Deployment

Deploying changes to the infrastructure of the data platform comprises different processes.
Currently, infrastructure is defined through Cloudformation stacks in yaml files. When changes 
are made and merged to main, the stacks must be manually updated in each environment.

## Lambda Functions
When changes are made to the code of the lambda functions, either first or third party, 
the code must be packaged and uploaded to the appropriate S3 bucket and the associated lambda
cloudformation stack redeployed to use the new version.

1. Once a PR with changes to the lambda code is merged to main, open a PR to update the version number defined
in the `pyproject.toml` file. 
2. On approval of this PR, confirm that the appropriate Github Action has run and created a zip file
of the lambda code.
3. Download the lambda zip file from the Github Action artifacts.
4. Run the `release_lambda.sh` script to upload the zip file to the appropriate S3 bucket and redeploy the lambda stack. 
The script has two dependencies that must be installed on your machine and available in your PATH:
- [AWS CLI](https://aws.amazon.com/cli/)
- yq 

The script takes four arguments:
- AWS profile name to use for the CLI - this requires that you have logged into the AWS cli and have saved [profiles](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-files.html) for the target accounts
- an evironment name - this must match the entries in the `deploy_config.yaml`. If you do not have this file, ask a team member for it
- the path to the lambda zip file that was downloaded from the Github Action artifacts
- the S3 prefix i.e. the folder in which the zip file should be uploaded

```bash
./release_lambda.sh <AWS_PROFILE> <environment> <path-to-lambda-zip> <s3-prefix>
```

This script will ask for your confirmation before deploying the changeset to the lambda stack.