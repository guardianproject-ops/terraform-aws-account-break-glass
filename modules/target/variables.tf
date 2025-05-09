variable "allow_break_glass" {
  type        = bool
  default     = true
  description = <<EOT
Controls whether to create an emergency access role (BreakGlassRole).

If set to true, creates a role that can be assumed by the AWS principal specified
in var.break_glass_principal with permissions defined by var.break_glass_policy_arn.
This role is intended for emergency access scenarios when normal access methods
are unavailable.

**Security Note**: Break glass access should be strictly controlled, audited, and
only used in genuine emergency situations.
EOT
}
variable "break_glass_principals" {
  type        = list(string)
  description = <<EOT
The AWS principal (account ID, IAM user ARN, or IAM role ARN) that is allowed to
assume the BreakGlassRole for emergency access.

Only used when var.allow_break_glass is set to true.

Format examples:
- AWS account: "arn:aws:iam::123456789012}:root"
- IAM user: "arn:aws:iam::123456789012:user/EmergencyUser"
- IAM role: "arn:aws:iam::123456789012:role/EmergencyAccessRole"
EOT
}

variable "break_glass_policy_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
  description = <<EOT
The ARN of the IAM policy to attach to the BreakGlassRole.

This policy defines the permissions granted during emergency access scenarios.
By default, uses AdministratorAccess.

Only used when var.allow_break_glass is set to true.
EOT
}

variable "break_glass_role_name" {
  type        = string
  default     = "BreakGlassRole"
  description = <<EOT
The name to assign to the emergency access IAM role created when var.allow_break_glass is true.

This role is designed for emergency scenarios when standard access methods are
unavailable or insufficient.  The name should be easily identifiable in IAM and
CloudTrail logs to facilitate proper auditing of emergency access events.

**Note**: If you change this from the default value, you must also change it in
the break glass account and ensure your break glass documentation and procedures
are updated accordingly so authorized personnel know which role to assume during
an emergency.
EOT
}
