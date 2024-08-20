import boto3
import os
import logging


def lambda_handler(event, context):
    if logging.getLogger().hasHandlers():
        # The Lambda environment pre-configures a handler logging to stderr. If a handler is already configured,
        # `.basicConfig` does not execute. Thus we set the level directly.
        logging.getLogger().setLevel(logging.INFO)
    else:
        logging.basicConfig(level=logging.INFO)

    logger = logging.getLogger("ecs_scale_down")

    ecs_client = boto3.client('ecs')
    cluster = os.environ.get('ECS_CLUSTER_NAME')
    dagit_service = os.environ.get("ECS_DAGIT_SERVICE_NAMES")
    daemon_service = os.environ.get("ECS_DAEMON_SERVICE_NAMES")
    code_service = os.environ.get("ECS_CODE_SERVER_SERVICE_NAMES")

    for service in (dagit_service, daemon_service, code_service):
        try:
            response = ecs_client.update_service(
                cluster=cluster,
                service=service,
                desiredCount=0
            )
            logger.info(f"Sucessfully scaled down Service {service}: {response}")
        except Exception as e:
            logger.error(f"Could not Scale Service {service}: {e}")
            continue


if __name__ == "__main__":
    print(lambda_handler(None,None))