import unittest
from unittest.mock import patch, Mock, call, MagicMock
from assign_group.handler import lambda_handler


class TestLambdaHandler(unittest.TestCase):
    @patch("os.environ.get")
    @patch("boto3.client")
    def test_lambda_handler(self, mock_boto_client, mock_get_env):
        mock_idp_client = Mock()
        mock_boto_client.return_value = mock_idp_client

        event = {"userPoolId": "test_pool_a890", "userName": "test.user"}

        res = lambda_handler(event, None)

        assert res == event

        mock_idp_client.admin_add_user_to_group.assert_has_calls(
            [
                call(
                    UserPoolId=event["userPoolId"],
                    Username=event["userName"],
                    GroupName="GeneralUserAccess",
                )
            ]
        )

    @patch("os.environ.get")
    @patch("boto3.client")
    def test_lambda_handler_missing_keys(self, mock_boto_client, mock_get_env):
        mock_idp_client = Mock()
        mock_boto_client.return_value = mock_idp_client

        event = {}
        with self.assertRaises(KeyError) as context:
            res = lambda_handler(event, None)

        mock_idp_client.admin_add_user_to_group.assert_not_called()
