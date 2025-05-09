resource "aws_iam_role" "break_glass" {
  count = var.allow_break_glass ? 1 : 0
  name  = var.break_glass_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowAssumeFromBreakGlass"
        Principal = {
          AWS = var.break_glass_principals
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "break_glass" {
  count      = var.allow_break_glass ? 1 : 0
  role       = aws_iam_role.break_glass[0].name
  policy_arn = var.break_glass_policy_arn
}
