variable "COMMON_TAGS" {
  default = {}  
}
variable "TAGS" {
  default = {}
}
variable "CREATE_INSTANCE_PROFILE" {
  default = false
}
variable "NAME" {
  type        = string
  default     = ""
}
variable "PATH" {
  type        = string
  default     = "/"
}
variable "STATEMENTS" {
  default = []
}
variable "VERSION" {
  default = "2012-10-17"
}
variable "POLICIES_ARN" {
  default = []
}
