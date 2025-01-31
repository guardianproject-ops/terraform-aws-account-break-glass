locals {
  enabled                = module.this.enabled
  break_glass_users      = local.enabled ? var.break_glass_users : {}
  break_glass_group_name = aws_iam_group.break_glass_access[0].name
}

resource "aws_iam_group" "break_glass_access" {
  count = local.enabled ? 1 : 0
  name  = var.break_glass_group_name
  path  = "/"
}

resource "aws_iam_group_policy_attachment" "perms" {
  count      = local.enabled ? 1 : 0
  group      = local.break_glass_group_name
  policy_arn = var.break_glass_policy_arn
}

data "aws_iam_policy_document" "break_glass_access" {
  statement {
    sid    = "BlockAccessUnlessSignedInWithMFA"
    effect = "Deny"
    not_actions = [
      "iam:ChangePassword",
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ListUsers",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice"
    ]
    resources = ["*"]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }

  statement {
    sid    = "BreakGlassAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = var.break_glass_role_arns
  }
}
resource "aws_iam_policy" "break_glass_access" {
  count  = local.enabled ? 1 : 0
  name   = "BreakGlassAccess-${module.this.id}"
  policy = data.aws_iam_policy_document.break_glass_access.json
}

resource "aws_iam_group_policy_attachment" "break_glass_access" {
  count      = local.enabled ? 1 : 0
  group      = local.break_glass_group_name
  policy_arn = aws_iam_policy.break_glass_access[0].arn
}

resource "aws_iam_user" "break_glass" {
  for_each = local.break_glass_users
  name     = each.value.email
  path     = "/"
  tags     = module.this.tags
}

resource "aws_iam_user_login_profile" "break_glass" {
  for_each                = local.break_glass_users
  user                    = aws_iam_user.break_glass[each.key].name
  password_length         = 25
  password_reset_required = true

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
}

resource "aws_iam_user_group_membership" "break_glass" {
  for_each = local.break_glass_users
  user     = aws_iam_user.break_glass[each.key].name
  groups = [
    local.break_glass_group_name
  ]
}
