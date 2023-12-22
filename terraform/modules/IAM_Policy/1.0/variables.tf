variable "NAME" {
  type        = string
  default     = ""
}

variable "PATH" {
  type        = string
  default     = "/"
}

variable "DESCRIPTION" {
  type        = string
  default     = "IAM Policy"
}

variable "POLICY" {
  default     = ""
}
variable "STATEMENTS" {}
variable "VERSION" {
  default = "2012-10-17"
}
variable "POLICY_JSON" {
  default = false
}
