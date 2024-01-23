resource "aws_guardduty_detector" "guardduty" {
  enable = true
  finding_publishing_frequency = "ONE_HOUR"

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = false
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }
}

/*resource "aws_sns_topic" "guardduty_alerts_topic" {
  name = "guardduty-alerts-topic"
}

resource "aws_guardduty_organization_admin_account" "example_organization_admin_account" {
  admin_account_id = "<ADMIN_ACCOUNT_ID>"  # Replace with your AWS account ID
}

resource "aws_guardduty_invite_accepter" "example_invite_accepter" {
  detector_id = aws_guardduty_detector.guardduty.id
}

resource "aws_guardduty_member" "example_member" {
  detector_id = aws_guardduty_detector.guardduty.id
  account_id  = "<MEMBER_ACCOUNT_ID>"  # Replace with the AWS account ID of the member account
  email       = "matthew.pugh@socialfinance.org.uk"   # Replace with the email address of the member account
}

resource "aws_guardduty_member_invitation" "example_member_invitation" {
  detector_id     = aws_guardduty_detector.guardduty.id
  account_id      = "<MEMBER_ACCOUNT_ID>"  # Replace with the AWS account ID of the member account
  email           = "matthew.pugh@socialfinance.org.uk"   # Replace with the email address of the member account
  sns_topic_arn   = aws_sns_topic.guardduty_alerts_topic.arn
}

output "guardduty_detector_id" {
  value = aws_guardduty_detector.guardduty.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.guardduty_alerts_topic.arn
}

/*

resource "aws_sqs_queue" "sqs_queue" {
  name                      = "Fons-IDS"
  delay_seconds             = 0
  receive_wait_time_seconds = 0
  receive_retention_seconds = 86400
  max_message_size          = 2048
  visibility_timeout        = 30
}

resource "aws_sns_topic" "guard_duty_sns_topic" {
  name         = "guardduty-event-topic"
  display_name = "guardduty-event-topic"
}

resource "aws_sns_subscription" "email_subscription" {
  protocol  = "email"
  topic_arn = aws_sns_topic.guard_duty_sns_topic.arn
  endpoint  = var.guard_duty_email
}

resource "aws_sns_topic_policy" "guard_duty_sns_topic_policy" {
  arn = aws_sns_topic.guard_duty_sns_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "Id1",
    Statement = [
      {
        Sid       = "Sid1",
        Effect    = "Allow",
        Principal = { Service = "events.amazonaws.com" },
        Action    = "sns:Publish",
        Resource  = aws_sns_topic.guard_duty_sns_topic.arn,
      },
    ],
  })
}

resource "aws_sns_topic_policy" "my_sns_to_sqs_policy" {
  arn = aws_sns_topic.guard_duty_sns_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "sqs.amazonaws.com" },
        Action    = "sns:Publish",
        Resource  = aws_sns_topic.guard_duty_sns_topic.arn,
      },
    ],
  })
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  name      = "SQSQueuePolicy"
  queue_url = aws_sqs_queue.sqs_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "SQSQueuePolicy",
    Statement = [
      {
        Sid       = "Allow-SendMessage-To-Queue-From-SNS-Topic",
        Effect    = "Allow",
        Principal = "*",
        Action    = ["sqs:SendMessage"],
        Resource  = "*",
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.guard_duty_sns_topic.arn,
          },
        },
      },
    ],
  })

  depends_on = [aws_sns_topic.guard_duty_sns_topic]
}

resource "aws_cloudwatch_event_rule" "guard_duty_event_rule" {
  name        = "guardduty-event-rule"
  description = "AWS GuardDuty event rule"
  event_pattern = jsonencode({
    source = ["aws.guardduty"],
  })

  depends_on = [aws_sns_topic.guard_duty_sns_topic]
}



resource "aws_cloudwatch_event_target" "guard_duty_event_target" {
  rule = aws_cloudwatch_event_rule.guard_duty_event_rule.name
  target_id = "GuardDutyEvent"
  arn = aws_sns_topic.guard_duty_sns_topic.arn
}*/