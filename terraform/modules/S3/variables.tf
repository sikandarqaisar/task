
variable "COMMON_TAGS" {
  default = {}
}
variable "TAGS" {
  default = {}
}
variable "BUCKET_NAME" {}
variable "VERSIONING" {
  default = true
}
variable "ACL" {
    default = "private"
}
variable "SSE_ALGORITHM" {
    default = "aws:kms"
}
