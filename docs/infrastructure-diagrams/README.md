# Deployment Structure
The service is deployed in several stages. 
1. the code is defined in github or another code version control system
2. The code is then pushed to an ECR repository
3. With each ECS service defined, it the task definition is set to pull from the ECR repository and run the service
4. Each account has its own pipeline setup that runs independently of each other

```mermaid
flowchart TB

%% Colors %%
    classDef white fill:white,stroke:#000,stroke-width:2px,color:#000
    classDef yellow fill:#fffdd5,stroke:#000,stroke-width:2px,color:#000
    classDef cyan fill:#94ffff,stroke:#000,stroke-width:2px,color:#000

subgraph gitops["Github / DevOps"]
    Dagster["Dagster Source"]
    CodeServer["Code Server Source"]
    FrontEnd["Front End Source"]
end

Dagster-->Dagit_ECR:::cyan
Dagster-->Daemon_ECR:::cyan
CodeServer-->CodeServer_ECR:::cyan
FrontEnd-->FE_ECR:::cyan

subgraph child["LA Account"]
    FE_Child_ECS["Frontend Service"]
    Dagit_Child_Service["Dagit Web Interface"]
    Daemon_Child_Service["Daemon/Dagster Service"]
    CodeServer_Child_Service["Code Server Service"]
    
    FE_Child_ECS --> FE_Child_Task["Frontend Task"]:::yellow
    Dagit_Child_Service-.Off By Default.->Dagit_Child_Task["Dagit Task"]:::yellow
    Daemon_Child_Service-->Daemon_Child_Task["Daemon Task"]:::yellow
    CodeServer_Child_Service-->CodeServer_Child_Task["Code Server Task"]:::yellow
end

FE_ECR --> FE_Child_ECS
FE_ECR --> FE_Org_ECS
Dagit_ECR --> Dagit_Child_Service
Dagit_ECR --> Dagit_Org_Service
CodeServer_ECR --> CodeServer_Child_Service
CodeServer_ECR --> CodeServer_Org_Service
Daemon_ECR --> Daemon_Child_Service
Daemon_ECR --> Daemon_Org_Service

subgraph organisation["Central Organisation Account"]
    FE_ECR["Frontend ECR"]
    Dagit_ECR["Dagit ECR"]
    Daemon_ECR["Daemon ECR"]
    CodeServer_ECR["Code Server ECR"]
    
    FE_Org_ECS["Frontend Service"]
    Dagit_Org_Service["Dagit Web Interface"]
    Daemon_Org_Service["Daemon/Dagster Service"]
    CodeServer_Org_Service["Code Server Service"]
    
    FE_Org_ECS --> FE_Org_Task["Frontend Task"]:::yellow
    Dagit_Org_Service-.Off By Default.->Dagit_Task["Dagit Task"]:::yellow
    Daemon_Org_Service-->Daemon_Task["Daemon Task"]:::yellow
    CodeServer_Org_Service-->CodeServer_Task["Code Server Task"]:::yellow
end
```

## The Services
Since each account's services are replicated, we can focus in on one of 
them to show the relationship of the different parts of the infrastructure.

How the service works is:
1. The user uploads files to the Frontend which then places them into the Data Store S3 Bucket
2. The Daster service picks up the file and runs it though the pipeline
3. In Intermediate stages, the file is stored in the "Workspace" S3 Folder
4. The final result of the processing is saved back into the data store with files stored in the shared bucket that 
will be accessible to the central organisation as needed.

The dagit service is a web interface used to view and manage schedules, but is turned
off by default. Long-term this will only be accessible via a secure channel such as VPN and used for
troubleshooting purposes. Even then, it will be off by default and need to be manually 
turned on.

The organisation account largely mirrors the one shown here, but I only mention the Daemon Service
to show how the two organisations connect.
```mermaid
flowchart TB

%% Colors %%
    classDef white fill:white,stroke:#000,stroke-width:2px,color:#000
    classDef yellow fill:#fffdd5,stroke:#000,stroke-width:2px,color:#000
    classDef cyan fill:#94ffff,stroke:#000,stroke-width:2px,color:#000
    classDef green fill:#94ff94,stroke:#000,stroke-width:2px,color:#000
    classDef red fill:#ff9494,stroke:#000,stroke-width:2px,color:#000

User
User-->Frontend

subgraph child["Local Authority Account"]
    subgraph vpn_fe["Frontend VPN"]
        subgraph public_fe["Frontend PUblic Subnet"]
            Frontend:::yellow
        end
    end
    subgraph vpn_dagster["Dagster VPN"]
        subgraph public["Private Dagit Subnet"]
            Dagit:::cyan
        end
        Dagit-.->|Off By Default|CodeServer["Code Server"]
        Dagit["Dagit Web Service"]-.->|Off By Default|Database
        Daemon["Daemon Service"]-->Database
        subgraph private["Private Subnet"]
            Daemon:::red-->CodeServer:::green
            CodeServer
            
        end
        subgraph database["Database Subnet"]
            Database[(Database)]
        end    
    end
    
    subgraph S3
        Workspace["Workspace S3 Bucket"]
        DataStore["Data Store S3 Bucket"]
        Shared["Shared Data S3 Bucket"]
    end
    Frontend-->DataStore
    Daemon-->Workspace
    Daemon-->DataStore
    Daemon-->Shared
end

OrgDaemon-->Shared

subgraph organisation["Organisation Account"]
    OrgDaemon["Daemon Service"]:::red
end
```

## Cross-Account Security
Security is handle via IAM roles and an AWS organisation structure. All accounts
are members of an "organisational unit", and as such communication
between them is restricted to only accounts that are part of that organisation AND
if the user has the required role that allows communication between the accounts.

There are two locations where this is important:
### ECR
ECS Tasks are given permission to access the ECR Repository on the
central account. This is so that a central location can be managed to 
handle the code for the tasks.

### S3
The "Shared" bucket is set so that a local authority can store files it wants
to share with the central organisation. Only files stored here will be accessible
by the organisation and not the other buckets (e.g. workspace and data store). Permission
to this bucket can be revoked by the local authority.

