# Infrastructure Instructions
The following is for setting up the platform on 
AWS accounts, though with some changes the platform 
can be deployed on any cloud or local environment 
as most of the actual code is contained in docker 
images and only needs a virtualisation service to run.

## Note about Run Launchers
If changing cloud providers, you may need to make 
changes to the dagster image that runs the dagit 
and daemon interfaces as they are currently 
set with `EcsRunLauncher` 
(See `/dagster/dagster.yaml`). 
If you wish to run on a different platform, this will 
need to be changed. [See here](https://docs.dagster.io/deployment/run-launcher) 
for details

## For multiple account setup
The multi-account setup creates a division between the uploaded files that LAs submit and the eventual 
files that regional authorities can access. To accomplish this, we have two accounts to maintain that division:
1. LA - Where LAs can upload files and have them cleaned and psuedonomised.
2. Organisation - Where the files that were created from the LA are combined with regional and other data (e.g. ONS, 
postcode, etc) to create output that can be used for analysis at a regional level.

Note: When ECS is used to run the Dagster code server, ECS will spin up a new container for each Dagster
job. Spinning up these containers requires pulling a docker image each time - in order to avoid rate 
limits, we need to authenticate to docker as a paid docker user. Social Finance has the docker Pro user
sysadmsocialfinance - the credentials are stored in the Secrets Manager in the SFDL Master AWS account. 
If the infrastructure/hosting responsibilities have been handed over to a client, the client must create their 
own docker user and store the associated credentials. If Social Finance are hosting the infrastructure, 
then after creating a new account, but before standing up the rest of the infrastructure:
1. Navigate to the AWS SFDL Master account 
2. Go to the Secrets Manager and select dockerhub-sysadmin-credentials-5Lb3FI
3. Edit the policy against the secret by adding f"arn:aws:iam::{account_id}:root" to the Principal. We cannot use
a specific role here as the role must exist before it is added to the IAM policy. In order to get around this, we give
access to the root user in the target account and it is the job of the target account to appropriately delegate access
to the role that needs it (defined in the CodeServerTaskExecutionRole in the dagster Cloudformation stack).
4. Still within the AWS SFDL Master account, navigate to the KMS
5. Go to the DataPlatform-ParameterStore-Key key -> Other AWS accounts and add the new account number
Note: a custom encryption key must be used and shared separately because AWS-managed keys cannot be shared across accounts.

In order to set this up, use the full directory in the cloudformation folder. Bring the infrastructure up in the following order:
1. Organisation
   1. common/ids.yaml
   2. organisation/sso1.yaml 
      * Send the output to the controlling organisation for their SSO setup (entity id and reply URL only)
      * Run SSO 2 when details are returned
   3. organisation/s3.yaml
      * Upload external data to the external data S3 bucket - this can be copied from
      staging
   4. common/general_key_access.yaml
      * Use the output from this to configure Heroku env vars.
   5. organisation/VPC.yaml
      * This step requires the SharedBucketARN from the LA - you can construct this:
      ```python
      f"arn:aws:s3:::fons-shared-{org}-prod"
      ```
   6. organisation/dagster.yaml
   7. common/scaling.yaml
      * Add the lambda zip file to the appropriate bucket before creating this infrastructure. Follow
      these [instructions](../infrastructure/environments/cloudformation/full/common/lambda/ecs_scale/README.md)
2. LA (taking the organisation account id as an input to allow access to the shared bucket.)
   1. common/ids.yaml
   2. la/sso1.yaml
      * Use the output of this to setup the azure application to hold users (same process as org) for 
      whoever will be managing LA users
      * Run SSO 2 when details are returned
   3. la/s3.yaml
      * The OrgAccountRoleArn required here is the CodeServerTaskRole from the Organisation infrastructure.
   4. common/general_key_access.yaml
      * Use the output from this to configure Heroku env vars.
   5. la/VPC.yaml
   6. la/dagster.yaml
   7. common/scaling.yaml
     * Add the lambda zip file to the appropriate bucket before creating this infrastructure. Follow
      these [instructions](../infrastructure/environments/cloudformation/full/common/lambda/ecs_scale/README.md)