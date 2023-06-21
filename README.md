# SFDATA Platform
This is a common approach to a data pipeline that is project-agnostic. This means that it should be able to be
reused and extended by other code bases to serve the need.

## Features
The core idea utilises the following:
1. Dagster setup via Docker / Docker compose. Changes could be made to make this something else such as Airflow, etc.
   1. The purpose of this type of deployment is to keep it flexible. Images can easily be run locally as well as on the 
   cloud infrastructure.
2. Dockerfiles can be pushed to a cloud infrastructure or locally. AWS terraform used as an example, but platform 
doesn't rely on this.
   1. AWS implementation Notes: 
      1. Images are pushed to ECR repos, and then spun up on ECS
      2. Files, such as pipeline code, are stored on cloud storage (such as S3) and synced in with dagster. A a separate 
      pipeline will accomplish this deployment.
