# Scaling Lambda

## Automated Process
There is a Github Action, called "Package Scaling Lambda" that will package 
this lambda function. To fully deploy, you need to upload to the relevant S3 bucket
and then update the lambda function to use the new zip file.

## Manual Process
To manually package this, do the following:

1. If it doesn't exist, make the package directory
```commandline
mkdir package
```
2. Next, we want to ensure all the libraries are present in the package:
```commandline
poetry run pip install --target ./package boto3
```
3. Zip Everything Up
```commandline
cd package
zip -r ../ecs-scaling-lambda.zip .
```
4. Add the lambda function handler to the zip
```commandline
cd ../ecs_scale
zip ../ecs-scaling-lambda.zip ./handler.py
```
5. The zip should have a flat directory structure, ready to be uploaded to s3
