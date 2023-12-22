
variable "REGION" {
    type    = string
    default = ""
}
variable "NAME" {
    default = ""
    type    = string
}
variable "VPC_CIDR" {
    default = ""
    type    = string
}
variable "AZS_COUNT" {
    default = 3
    type    = number
}
variable "PUBLIC_SUBNETS" {
    default = []
    type    = list(string)
}
variable "PRIVATE_SUBNETS" {
    default = []
    type    = list(string)
}
variable "PRIVATE_SUBNETS_WITHOUT_NG" {
    default = []
    type    = list(string)
}
variable "TAGS" {
    default = {
        "TagKey" = "TagValue",
    }
}
