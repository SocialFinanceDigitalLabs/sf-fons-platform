# Datadog Integration
Data dog integration has several aspects. Most of these are set by Data dog themselves.
We should generally use the latest version of the Integration and Log Uploader from their
panel. I've included copies here, however for eas of access. The scheduler and Subscription
options are created by us using the 
[data dog docs](https://docs.datadoghq.com/logs/guide/send-aws-services-logs-with-the-datadog-lambda-function/?tab=cloudformation#automatically-set-up-triggers) 
as a guide.

## Integration (Datadog managed)
This allows datadog to integrate with the AWS account. This means
it can look for and detect unusual activity

## Log Uploader (Data dog managed)
This is specific to allowing datadog to access logs. The lambda function will surface
logs that it's subscribed to (see below) and send them to Datadog

## Log Uploader Scheduler (SF Managed)
This was added by myself to trigger the log uploader on a schedule we can define. There
are other ways to surface this, but in order to control costs I've determined that we should
probably keep uploading to a controllable pattern

## Subscription (SF Managed)
This subscribes the log uploader lambda to different log groups. For the data platform,
this generally means 4 services:
* ECS - Dagster Daemon
* ECS - Dasgter Webserver
* ECS - Dagster Code Server
* Lambda - Scaling lambda (what turns the above three on and off on a schedule)


