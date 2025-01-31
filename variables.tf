variable "break_glass_users" {
  type = map(object({
    email = string
  }))
  description = <<-EOT
Map of the users that will be created and added to the break glass IAM group.
The map key is a unique/non-changing identifier for the user, and the value is an object containing configuration variables for the user.
EOT
}

variable "break_glass_role_arns" {
  type        = list(string)
  default     = ["arn:aws:iam::*:role/BreakGlassRole"]
  description = <<-EOT
The ARN of the IAM role that will be assumed by the break glass group in other accounts.
This allows the break glass users to switch role into the break glass role in other accounts.
EOT
}

variable "break_glass_group_name" {
  type        = string
  default     = "BreakGlassAccess"
  description = <<-EOT
The name of the IAM group that will be created to provide break glass access to the AWS accounts.
EOT
}

variable "break_glass_policy_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/IAMFullAccess"
  description = <<-EOT
The ARN of the IAM policy that will be attached to the break glass IAM group inside the break glass account.
EOT
}
