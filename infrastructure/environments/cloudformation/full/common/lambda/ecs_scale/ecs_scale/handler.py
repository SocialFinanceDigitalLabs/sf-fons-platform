import boto3
import os
import logging


def lambda_handler(event, context):
    # Will be fed by the event rule if the pipeline is to be turned on or off
    if event["pipelineStatus"] == "true":
        pipeline_count = 1
    elif event["pipelineStatus"] == "false":
        pipeline_count = 0

    # On staging systems, we want to make sure to reload the pipeline every time.
    # On production systems, we should use cached version unless there's an infrastructure update
    force_new_deployment = False if os.environ.get("ENVIRONMENT") == "prod" else True

    if logging.getLogger().hasHandlers():
        # The Lambda environment pre-configures a handler logging to stderr. If a handler is already configured,
        # `.basicConfig` does not execute. Thus we set the level directly.
        logging.getLogger().setLevel(logging.INFO)
    else:
        logging.basicConfig(level=logging.INFO)

    logger = logging.getLogger("ecs_scaler")

    ecs_client = boto3.client("ecs")
    cluster = os.environ.get("ECS_CLUSTER_NAME")
    dagit_service = os.environ.get("ECS_DAGIT_SERVICE_NAMES")
    daemon_service = os.environ.get("ECS_DAEMON_SERVICE_NAMES")
    code_service = os.environ.get("ECS_CODE_SERVER_SERVICE_NAMES")

    for service in (dagit_service, daemon_service, code_service):
        try:
            response = ecs_client.update_service(
                cluster=cluster,
                service=service,
                desiredCount=pipeline_count,
                forceNewDeployment=force_new_deployment,
            )
            logger.info(
                f"Successfully scaled Service {service} to {pipeline_count}: {response}"
            )
        except Exception as e:
            logger.error(f"Could not Scale Service {service} to {pipeline_count}: {e}")
            continue


if __name__ == "__main__":
    print(lambda_handler(None))
