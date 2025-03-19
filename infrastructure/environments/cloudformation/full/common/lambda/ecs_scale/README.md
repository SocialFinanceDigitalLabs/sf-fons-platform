# Scaling Lambda

## Manual Process
To package this, do the following:

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

## Automated Process
To do. The above process could be done via a github actions and then an upload step could push this to s3,
and redeployed to the lambda. 