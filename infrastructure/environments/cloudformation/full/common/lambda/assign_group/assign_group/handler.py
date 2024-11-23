"""
This module assigns a user to a standard user group after they login.
"""
import logging
import boto3

def lambda_handler(event, context):
    """
    :param event: AWS Lambda event object containing Cognito sign-in information
    :param context: AWS Lambda context object
    :return: Modified event with successful processing
    """
    cognito_idp = boto3.client("cognito-idp")

    try:
        user_pool_id = event["userPoolId"]
        username = event["userName"]
    except KeyError as err:
        logging.error("Could not get required information from event: %s", err)
        raise

    try:
        cognito_idp.admin_add_user_to_group(
            UserPoolId=user_pool_id, Username=username, GroupName="GeneralUserAccess"
        )
    except cognito_idp.Client.exceptions.InvalidParameterException as err:
        logging.error("Invalid parameter specified when assigning to group: %s", err)
    except cognito_idp.Client.exceptions.ResourceNotFoundException as err:
        logging.error("Can't find user pool")
    except cognito_idp.Client.exceptions.TooManyRequestsException:
        logging.error(
            "User group assignment failed due to too many requests on the service"
        )
    except cognito_idp.Client.exceptions.NotAuthorizedException:
        logging.error("Don't have permission to add user to group")
    except cognito_idp.Client.exceptions.UserNotFoundException:
        logging.error("User not found in pool")
    except Exception as err:
        logging.error("An unexpected error has occurred: %s", err)

    return event
