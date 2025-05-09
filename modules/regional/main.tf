data "aws_region" "current" {}
module "label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  name       = "audit"
  attributes = [data.aws_region.current.id]
  enabled    = module.this.enabled
}

locals {
  audit_enabled = module.label.enabled
  topic_arn     = local.audit_enabled ? aws_sns_topic.audit[0].arn : ""
  email_enabled = local.audit_enabled && var.alert_email_address != null
}

########### SNS

resource "aws_sns_topic" "audit" {
  count = local.audit_enabled ? 1 : 0
  name  = module.label.id
}

resource "aws_sns_topic_subscription" "email" {
  count     = local.email_enabled ? 1 : 0
  topic_arn = local.topic_arn
  protocol  = "email"
  endpoint  = var.alert_email_address
}

resource "aws_sns_topic_subscription" "this" {
  for_each = local.audit_enabled ? var.subscribers : {}

  topic_arn              = local.topic_arn
  protocol               = var.subscribers[each.key].protocol
  endpoint               = var.subscribers[each.key].endpoint
  endpoint_auto_confirms = var.subscribers[each.key].endpoint_auto_confirms
  filter_policy          = var.subscribers[each.key].filter_policy
  filter_policy_scope    = var.subscribers[each.key].filter_policy_scope
  raw_message_delivery   = var.subscribers[each.key].raw_message_delivery
}

resource "aws_sns_topic_policy" "audit" {
  count  = local.audit_enabled ? 1 : 0
  arn    = local.topic_arn
  policy = data.aws_iam_policy_document.audit.json
}

data "aws_iam_policy_document" "audit" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [local.topic_arn]
  }
}
########### Cloudwatch

resource "aws_cloudwatch_event_rule" "login_event" {
  count       = local.audit_enabled ? 1 : 0
  name        = "capture-user-sign-in-${module.this.id}"
  description = "Capture the sign in event of any user"

  event_pattern = jsonencode({
    detail = {
      eventName   = ["ConsoleLogin"]
      eventSource = ["signin.amazonaws.com"]
      userIdentity = {
        type = ["IAMUser", "Root", "AssumedRole"]
      }
    }
    "detail-type" = ["AWS Console Sign In via CloudTrail"]
    source        = ["aws.signin"]
  })
}

resource "aws_cloudwatch_event_target" "login_target" {
  count     = local.audit_enabled ? 1 : 0
  rule      = aws_cloudwatch_event_rule.login_event[0].name
  target_id = "SendToSNS-${module.this.id}"
  arn       = local.topic_arn
}

resource "aws_cloudwatch_event_rule" "switch_event" {
  count       = local.audit_enabled ? 1 : 0
  name        = "capture-user-switch-role-${module.this.id}"
  description = "Capture user switching roles"

  event_pattern = jsonencode({
    detail = {
      eventName   = ["SwitchRole"]
      eventSource = ["signin.amazonaws.com"]
      userIdentity = {
        type = ["IAMUser", "Root"]
      }
    }
    "detail-type" = ["AWS Console Sign In via CloudTrail"]
    source        = ["aws.signin"]
  })
}

resource "aws_cloudwatch_event_target" "switch_target" {
  count     = local.audit_enabled ? 1 : 0
  rule      = aws_cloudwatch_event_rule.switch_event[0].name
  target_id = "SendToSNS-${module.this.id}"
  arn       = local.topic_arn
}


resource "aws_cloudwatch_event_rule" "assume_event" {
  count       = local.audit_enabled ? 1 : 0
  name        = "capture-user-assume-role-${module.this.id}"
  description = "Capture user assuming roles"

  event_pattern = jsonencode({
    source        = ["aws.sts"]
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["sts.amazonaws.com"]
      eventName   = ["AssumeRole"]
      userIdentity = {
        type = ["IAMUser", "Root"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "assume_target" {
  count     = local.audit_enabled ? 1 : 0
  rule      = aws_cloudwatch_event_rule.assume_event[0].name
  target_id = "SendToSNS-${module.this.id}"
  arn       = local.topic_arn
}


resource "aws_cloudwatch_event_rule" "assume_saml_event" {
  count       = local.audit_enabled ? 1 : 0
  name        = "capture-saml-user-assume-role-${module.this.id}"
  description = "Capture saml user assuming roles"

  event_pattern = jsonencode({
    source        = ["aws.sts"]
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["sts.amazonaws.com"]
      eventName   = ["AssumeRoleWithSAML"]
    }
  })
}

resource "aws_cloudwatch_event_target" "assume_saml_target" {
  count     = local.audit_enabled ? 1 : 0
  rule      = aws_cloudwatch_event_rule.assume_saml_event[0].name
  target_id = "SendToSNS-${module.this.id}"
  arn       = local.topic_arn
}
