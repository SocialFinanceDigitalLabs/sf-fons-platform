import os
import unittest
from unittest.mock import patch, Mock, call, MagicMock
from ecs_scale_up.handler import lambda_handler
import logging

class TestLambdaHandler(unittest.TestCase):

    @patch('os.environ.get')
    @patch('boto3.client')
    def test_lambda_handler(self, mock_boto_client, mock_get_env):
        # Mock environment variables
        mock_get_env.side_effect = (
            'my-cluster',  # Return 'my-cluster' for 'ECS_CLUSTER_NAME'
            'dagit-service',  # Return 'dagit-service' for 'ECS_DAGIT_SERVICE_NAMES'
            'daemon-service',  # Return 'daemon-service' for 'ECS_DAEMON_SERVICE_NAMES'
            'code-server-service',  # Return 'code-server-service' for 'ECS_CODE_SERVER_SERVICE_NAMES'
        )

        mock_ecs_client = Mock()
        mock_boto_client.return_value = mock_ecs_client

        # Mock ecs_client.update_service with a Mock object
        mock_update_service = Mock(return_value={'some': 'response'})

        # Invoke the Lambda function with a sample event (optional)
        event = {'key': 'value'}  # You can provide a sample event here if needed

        lambda_handler(event, None)  # Pass context=None for mocking

        # Assertions to verify function behavior
        mock_get_env.assert_has_calls([
            call('ECS_DAGIT_SERVICE_NAMES'),
            call('ECS_DAEMON_SERVICE_NAMES'),
            call('ECS_CODE_SERVER_SERVICE_NAMES'),
        ])

        mock_ecs_client.update_service.assert_has_calls([
            call(cluster='my-cluster', service='dagit-service', desiredCount=1),
            call(cluster='my-cluster', service='daemon-service', desiredCount=1),
            call(cluster='my-cluster', service='code-server-service', desiredCount=1)
        ])



