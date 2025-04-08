import boto3
import logging

logger = logging.getLogger()
logger.setLevel("INFO")

cognito_client = boto3.client("cognito-idp")


def get_user(user_pool_id: str, user_name: str) -> dict:
    """
    This gets the user object (and attributes) from cognito
    user pool.

    ATTRIBUTES
    user_pool_id: The user pool id
    user_name: the username to get attributes for
    return: the user object, defined here: https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_AdminGetUser.html
    """
    try:
        response = cognito_client.admin_get_user(
            UserPoolId=user_pool_id, Username=user_name
        )
    except cognito_client.exceptions.UserNotFoundException:
        logger.warning(f"Error: User '{user_name}' not found.")
        return None
    except Exception as e:
        logger.error(f"An error occurred")
        raise e

    return response


def check_and_update_attribute(
    user_pool_id: str,
    user_name: str,
    user_attributes: dict,
    attribute_name: str,
    new_attribute_value: str,
) -> bool:
    """
    This checks a specified attribute, if it exists in the cognito user object,
    and if it matches the incoming attribute value. If there's a difference, updates
    are done if that's the case.

    See here for the AWS API doc
    https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_AdminUpdateUserAttributes.html

    ATTRIBUTES
    user_pool_id: The user pool id
    user_name: the username to check
    user_attributes: the user attributes retrieved from Cognito
    new_attribute_value: the attribute value incoming from the SSO object
    return: true if the check was done successfully (update or not), False if errors encountered
    """
    for attribute in user_attributes:
        if attribute["Name"] == attribute_name:
            if attribute["Value"] == new_attribute_value:
                logger.info(f"No updates needed for {user_name}")
                return True
            else:
                logger.info(
                    f"Updating attributes for {user_name} from {attribute['Value']} to {new_attribute_value}"
                )

                try:
                    update_response = cognito_client.admin_update_user_attributes(
                        UserPoolId=user_pool_id,
                        Username=user_name,
                        UserAttributes=[
                            {"Name": "locale", "Value": new_attribute_value},
                        ],
                    )
                    logger.info(f"Attributes updated for {user_name}")
                    return True
                except cognito_client.exceptions.UserNotFoundException:
                    logger.error(
                        f"User not found: {user_name}. Can't update attributes."
                    )
                    return False
                except Exception as e:
                    logger.error(
                        f"An error occurred while updating locale for user '{user_name}': {e}"
                    )
                    return False
    return False


def lambda_handler(event, context):
    """
    Post-authentication trigger to verify event attributes against user attributes in Cognito.
    """

    user_pool_id = event["userPoolId"]
    user_name = event["userName"]
    event_attributes = event["request"]["userAttributes"]

    response = get_user(user_pool_id, user_name)
    if response == None:
        return event

    result = check_and_update_attribute(
        user_pool_id,
        user_name,
        response["UserAttributes"],
        "locale",
        event_attributes["locale"],
    )

    if result:
        return event
    else:
        logger.error("User attribute update unsuccessful")
        return event