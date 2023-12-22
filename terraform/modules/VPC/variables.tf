variable "AVAILABILITY_ZONES" {}
variable "NAME" {
    default = ""
}
variable "TAGS" {
  default = {}
}
variable "VPC_CIDR" {
    default = ""
}
variable "INSTANCE_TENANCY" {
    default = "default"
}
variable "AZS_COUNT" {
    default = 3
}
variable "PUBLIC_SUBNETS" {
    default = []
}
variable "PRIVATE_SUBNETS" {
    default = []
}
variable "PRIVATE_SUBNETS_WITHOUT_NG" {
    default = []
}
variable "ENABLE_DNS_HOSTNAMES" {
    default = true
}
variable "ENABLE_DNS_SUPPORT" {
    default = true
}
variable "ENABLE_NAT_GATEWAY" {
    default = true
}
variable "SINGLE_NAT_GATEWAY" {
    default = false
}
variable "ONE_NAT_GATEWAY_PER_AZ" {
    default = true
}
variable "MAP_PUBLIC_IP_ON_LAUNCH" {
    default = true
}
variable "COMMON_TAGS" {
    default = {}
}