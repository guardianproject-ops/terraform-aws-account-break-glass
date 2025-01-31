variable "alert_email_address" {
  description = "An optional email address that will be alerted when Break Glass users are used"
  type        = string
  default     = null
}

variable "subscribers" {
  type = map(object({
    protocol = string
    # The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially supported, see below) (email is an option but is unsupported, see below).
    endpoint = string
    # The endpoint to send data to, the contents will vary with the protocol. (see below for more information)
    endpoint_auto_confirms = optional(bool, false)
    # Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty (default is false)
    filter_policy = optional(string, null)
    # The filter policy JSON that is assigned to the subscription. For more information, see Amazon SNS Filter Policies.
    filter_policy_scope = optional(string, null)
    # The filter policy scope that is assigned to the subscription. Whether the `filter_policy` applies to `MessageAttributes` or `MessageBody`. Default is null.
    raw_message_delivery = optional(bool, false)
    # Boolean indicating whether or not to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property) (default is false)
  }))
  description = "Required configuration for subscibres to SNS topic."
  default     = {}
}
