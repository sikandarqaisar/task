###################
# LaunchTemplate
###################
variable "COMMON_TAGS" {
  default = {}
}
variable "TAGS" {
  default = {}
}
variable "IMAGE_ID" {}
variable "INSTANCE_TYPE" {}
variable "ASG_IAM_INSTANCE_PROFILE_NAME" {}
variable "ASG_SECURITY_GROUP_IDS" {}
variable "EBS_OPTIMIZED" {
  default = false
}
variable "TEMPLATE_NAME" {
  type        = string
}
variable "ASG_EBS_BLOCK_DEVICE" {}

###################
# AutoScaling
###################

variable "ASG_NAME" {}
variable "ASG_SUBNET_IDS" {
  description = "A list of subnet IDs to launch resources in"
  type        = list(string)
}
variable "ASG_MAX_SIZE" {
  description = "The maximum size of the auto scale group"
  type        = number
}
variable "ASG_MIN_SIZE" {
  description = "The minimum size of the auto scale group"
  type        = number
}
variable "ASG_DESIRED_CAPACITY" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = number
}
variable "ASG_TARGET_GROUP_ARNS" {
  default = []
}
variable "INSTANCE_TAGS" {}