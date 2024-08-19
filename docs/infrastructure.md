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

## Steps (for single account setup)

1. Create AWS Account
2. Create A [Task Execution Role] (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html#create-task-execution-role).  This has not yet been added to the cloudformation.
3. Run cloudformation scripts in the following order in `/infrastructure/environments/cloudformation/interim`. You will need to make note of the output variables specified in each stepp for the ones following.
   1. IDS
   2. S3
   3. SSO1
   4. SSO2 (select the one for your SSO provider. Most should be Azure)
   5. Frontend_ec2
   6. VPC
   7. Dagster

# For multiple account setup
The multi-account setup creates a division between the uploaded files that LAs submit and the eventual 
files that regional authorities can access. To accomplish this, we have two accounts to maintain that division:
1. LA - Where LAs can upload files and have them cleaned and psuedonomised.
2. Organisation - Where the files that were created from the LA are combined with regional and other data (e.g. ONS, 
postcode, etc) to create output that can be used for analysis at a regional level.

In order to set this up, use the full directory in the cloudformation folder. Bring the infrastructure up in the following order:
1. Organisation
2. LA (taking the organisation account id as an input to allow access to the shared bucket.)

Otherwise the order of how files are applied in each account remains the same for the single account setup (above).