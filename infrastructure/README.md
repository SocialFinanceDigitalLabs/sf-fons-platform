Steps:

1. Terraform to deploy ECR (repositories), and the rest of the infrastructure
2. docker-compose to build images and deploy to ECR
3. Pipeline code is put onto S3, and then synced with dagster images.
4. Sync operation makes sure that the code and dagster are up to date.