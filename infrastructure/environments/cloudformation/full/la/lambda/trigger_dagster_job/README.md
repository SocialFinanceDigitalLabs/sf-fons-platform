# Trigger Dagster Job Lambda

This lambda function is designed to trigger a Dagster job by sending a GraphQL mutation
to the Dagster Webserver (formerly Dagit). To do this, the lambda will first scale
up the Dagster Webserver ECS service to ensure there is at least one running task. Once
the webserver endpoint is reachable, the mutation is sent to trigger the job. Then the
ECS service is scaled back down to zero tasks.

## Automated Process
There is a Github Action, called "Package Trigger Dagster Lambda" that will package 
this lambda function. To fully deploy, you need to upload to the relevant S3 bucket
and then update the lambda function to use the new zip file.

## Manual Process
If the Github Action fails, you can manually package this:

1. If it doesn't exist, make the package directory
```commandline
mkdir package
```
2. Lint your code
```commandline
poetry run ruff check trigger_dagster_job/handler.py --fix
poetry run black trigger_dagster_job/handler.py
```
3. Next, we want to ensure all the libraries are present in the package:
```commandline
poetry run pip install --target ./package boto3 requests
```
4. Zip Everything Up
```commandline
cd package
zip -r ../trigger-dagster-job.zip .
```
5. Add the lambda function handler to the zip
```commandline
cd ../trigger_dagster_job
zip ../trigger-dagster-job.zip ./handler.py
```
6. The zip should have a flat directory structure, ready to be uploaded to s3
