import json

import boto3
import os
import requests
import time
import logging

ecs = boto3.client("ecs")

CLUSTER = os.environ["ECS_CLUSTER_NAME"]
SERVICE = os.environ["ECS_DAGIT_SERVICE_NAME"]
PRIVATE_NAMESPACE = os.environ["PRIVATE_NAMESPACE"]

MAX_HEALTH_WAIT = 120  # Webserver spin-up limit
WEBSERVER_REQUEST_TIMEOUT = 5
DAGSTER_WEBSERVER_URL = f"http://dagster-webserver.{PRIVATE_NAMESPACE}:3000/"

if logging.getLogger().hasHandlers():
    # The Lambda environment pre-configures a handler logging to stderr. If a handler is already configured,
    # `.basicConfig` does not execute. Thus we set the level directly.
    logging.getLogger().setLevel(logging.INFO)
else:
    logging.basicConfig(level=logging.INFO)

logger = logging.getLogger("one_off_dagster_job")


def scale_service(count: int):
    ecs.update_service(cluster=CLUSTER, service=SERVICE, desiredCount=count)
    logger.info(f"Scaled {SERVICE} to desiredCount={count}")


def wait_for_dagster_health():
    logger.info("Waiting for Dagster GraphQL endpoint to become healthy...")
    start = time.time()
    while time.time() - start < MAX_HEALTH_WAIT:
        try:
            resp = requests.get(
                DAGSTER_WEBSERVER_URL, timeout=WEBSERVER_REQUEST_TIMEOUT
            )
            if resp.status_code == 200:
                logger.info("Dagster webserver healthy.")
                return
        except Exception as e:
            logger.error(e)
        time.sleep(5)
    raise TimeoutError("Dagster webserver did not become healthy in time.")


def lambda_handler(event, context):
    run_config = {
        "ops": {
            "create_session_folder": {
                "config": {
                    "dataset_folder": "s3://fons-data-store-la-staging/TestLA1-4346b-TT1/annex_a/",
                    "la_folder": "s3://fons-data-store-la-staging/TestLA1-4346b-TT1/",
                    "input_la_code": "TT1",
                    "dataset": "annex_a",
                }
            },
            "open_current": {
                "config": {
                    "dataset_folder": "s3://fons-data-store-la-staging/TestLA1-4346b-TT1/annex_a/",
                    "la_folder": "s3://fons-data-store-la-staging/TestLA1-4346b-TT1/",
                    "input_la_code": "TT1",
                    "dataset": "annex_a",
                }
            },
            "process_files": {
                "config": {
                    "dataset_folder": "s3://fons-data-store-la-staging/TestLA1-4346b-TT1/annex_a/",
                    "la_folder": "s3://fons-data-store-la-staging/TestLA1-4346b-TT1/",
                    "input_la_code": "TT1",
                    "dataset": "annex_a",
                }
            },
        }
    }

    #  """Launch a Dagster job by spinning up a webserver/Dagit ECS Service, triggering via GraphQL, and tearing it down."""
    job_name = event["job_name"]

    try:
        scale_service(1)
        wait_for_dagster_health()

        graphql_url = f"{DAGSTER_WEBSERVER_URL}graphql"
        mutation = {
            "query": """
            mutation LaunchRunMutation(
                $repositoryLocationName: String!
                $repositoryName: String!
                $jobName: String!
                $runConfigData: RunConfigData!
                ) {
                launchRun(
                    executionParams: {
                    selector: {
                        repositoryLocationName: $repositoryLocationName
                        repositoryName: $repositoryName
                        jobName: $jobName
                    }
                    runConfigData: $runConfigData
                    }
                ) {
                    __typename
                    ... on LaunchRunSuccess {
                    run {
                        runId
                    }
                    }
                    ... on RunConfigValidationInvalid {
                    errors {
                        message
                        reason
                    }
                    }
                    ... on PythonError {
                    message
                    }
                }
            }""",
            "variables": {
                "repositoryLocationName": "user_code",
                "repositoryName": "sync",
                "jobName": job_name,
                "runConfigData": run_config,
            },
        }
        response = requests.post(
            graphql_url, json=mutation, timeout=WEBSERVER_REQUEST_TIMEOUT
        )
        logger.info(f"Successfully started {job_name} job.")

        return {
            "statusCode": 200,
            "body": json.loads(json.dumps(response, default=str)),
        }

    except Exception as e:
        logger.error(f"Error: {e}")
        raise e

    finally:
        # Always scale back down
        try:
            scale_service(0)
        except Exception as cleanup_error:
            logger.error(f"Failed to scale down webserver: {cleanup_error}")
