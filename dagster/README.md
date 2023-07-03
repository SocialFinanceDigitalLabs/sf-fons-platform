# Dagster
This is the docker images used in production for Dagster. 

## How to Run Locally
Make sure you have [docker](http://www.docker.io) installed. 

You'll need to copy the `.env.sample` file to `.env` and make sure you set the correct values

Then run the following commands:

1. docker compose build - This will build the images based on the instructions in the docker files
2. docker compose up - This will run the docker files generated in step 1 and connect them as per the 
instructions in the `docker-0compose.yaml` file. 

## How it works
The current design is spin up several images as follows:
### Dagit
### Dagster Daemon
### User Code Server

```mermaid
graph TB;

subgraph one[Core AWS Account]
A[Dagit ECR]
B[Dagster Daemon]
end

subgraph two[LA1 AWS Account]
A-->C[Dagit Live]
B-->D[Daemon Live]
G[Code Server Image]-->H[Code Server Live]
end

subgraph three[LA2 AWS Account]
A-->E[Dagit Live]
B-->F[Daemon Live]
I[Code Server Image]-->J[Code Server Live]
end


```
