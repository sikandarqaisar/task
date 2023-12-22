variable "COMMON_TAGS" {
  default = {}
}
variable "TAGS" {
  default = {}
}
###################
##### Application Load Balancer
###################

variable "ALB_SUBNET_IDS" {
  default = []
}
variable "ALB_SECURITY_GROUP_IDS" {
  default = []
}
variable "ALB_SUBNET_MAPPING" {
  default = []
}
variable "ALB_NAME" {}


###################
###### Target Groups
###################
variable "ALB_TARGET_GROUPS" {
  default = []
}
variable "ALB_VPC_ID" {}
variable "ALB_HTTP_TCP_LISTENERS" {
  default = []
}