locals {
  max_subnet_length = max(length(var.PRIVATE_SUBNETS),)
  azs               = length("${var.PUBLIC_SUBNETS}") >= "${var.AZS_COUNT}" ? slice("${var.AVAILABILITY_ZONES}", 0, "${var.AZS_COUNT}") : slice("${var.AVAILABILITY_ZONES}", 0, length("${var.PUBLIC_SUBNETS}"))
  un_used_azs       = "${var.AZS_COUNT}" >= length("${var.AVAILABILITY_ZONES}") ? "${var.AVAILABILITY_ZONES}" : slice("${var.AVAILABILITY_ZONES}", 0, "${var.AZS_COUNT}")
  nat_gateway_count = var.SINGLE_NAT_GATEWAY ? 1 : var.ONE_NAT_GATEWAY_PER_AZ ? length(local.azs) : local.max_subnet_length
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
######
# VPC
######
resource "aws_vpc" "this" {
  cidr_block                       = var.VPC_CIDR
  instance_tenancy                 = var.INSTANCE_TENANCY
  enable_dns_hostnames             = var.ENABLE_DNS_HOSTNAMES
  enable_dns_support               = var.ENABLE_DNS_SUPPORT

  tags = merge(
    {
      "Name" = format("%s", var.NAME)
    },
    var.COMMON_TAGS,
    var.TAGS,    
  )
}


#######
# VPC Flow Logs
#######

/* resource "aws_flow_log" "flow_logs" {
  count = var.CREATE_VPC_FLOW_LOGS == true ? 1 : 0

  log_destination      = "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-logging"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
} */


###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = length(var.PUBLIC_SUBNETS) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s", var.NAME)
    },
    var.COMMON_TAGS,
    var.TAGS,    
  )
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = length(var.PUBLIC_SUBNETS) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-Public-RouteTable", var.NAME)
    },
    var.COMMON_TAGS,
    var.TAGS,    
  )
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.PUBLIC_SUBNETS) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
#################
resource "aws_route_table" "private" {
  count = local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = var.SINGLE_NAT_GATEWAY ? "${var.NAME}-Private-Route-Table" : format(
        "%s-Private-RouteTable-%s",
        var.NAME,
        element(local.azs, count.index),
      )
    },
    var.COMMON_TAGS,
    var.TAGS,    
  )
}


################
# Public subnet
################
resource "aws_subnet" "public" {
  count = length(var.PUBLIC_SUBNETS) > 0 && (false == var.ONE_NAT_GATEWAY_PER_AZ || length(var.PUBLIC_SUBNETS) >= length(local.azs)) ? length(var.PUBLIC_SUBNETS) : 0

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(concat(var.PUBLIC_SUBNETS, [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) > 0 ? element(local.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) == 0 ? element(local.azs, count.index) : null
  map_public_ip_on_launch         = var.MAP_PUBLIC_IP_ON_LAUNCH

  tags = merge(
    {
      "Name" = format(
        "%s-PublicSubnet-%s",
        var.NAME,
        count.index,
      )
    },
    var.COMMON_TAGS,
    var.TAGS,    
  )
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = length(var.PRIVATE_SUBNETS) > 0 ? length(var.PRIVATE_SUBNETS) : 0

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = var.PRIVATE_SUBNETS[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) > 0 ? element(local.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) == 0 ? element(local.azs, count.index) : null

  tags = merge(
    {
      "Name" = format(
        "%s-PrivateSubnet-%s",
        var.NAME,
        count.index,
      )
    },
    var.COMMON_TAGS,
    var.TAGS,    
  )
}

resource "aws_subnet" "private_without_nat_gateway" {
  count = length(var.PRIVATE_SUBNETS_WITHOUT_NG) > 0 ? length(var.PRIVATE_SUBNETS_WITHOUT_NG) : 0

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = var.PRIVATE_SUBNETS_WITHOUT_NG[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(local.un_used_azs, count.index))) > 0 ? element(local.un_used_azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(local.un_used_azs, count.index))) == 0 ? element(local.un_used_azs, count.index) : null

  tags = merge(
    {
      "Name" = format(
        "%s-PrivateSubnet-WithoutNG-%s",
        var.NAME,
        count.index,
      )
    },
    var.COMMON_TAGS,
    var.TAGS,    
  )
}


##############
# NAT Gateway
##############
locals {
  nat_gateway_ips = split(
    ",",
    join(",", aws_eip.nat.*.id),    
  )
}

resource "aws_eip" "nat" {
  count = length(var.PRIVATE_SUBNETS) > 0 && var.ENABLE_NAT_GATEWAY ? local.nat_gateway_count : 0
  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.NAME,
        element(local.azs, var.SINGLE_NAT_GATEWAY ? 0 : count.index),
      )
    },
    var.COMMON_TAGS,
    var.TAGS,    
  )
}

resource "aws_nat_gateway" "this" {
  count = length(var.PRIVATE_SUBNETS) > 0 && var.ENABLE_NAT_GATEWAY ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.SINGLE_NAT_GATEWAY ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public.*.id,
    var.SINGLE_NAT_GATEWAY ? 0 : count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.NAME,
        element(local.azs, var.SINGLE_NAT_GATEWAY ? 0 : count.index),
      )
    },
    var.COMMON_TAGS,
    var.TAGS,    
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  count = length(var.PRIVATE_SUBNETS) > 0 && var.ENABLE_NAT_GATEWAY ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = length(var.PRIVATE_SUBNETS) > 0 ? length(var.PRIVATE_SUBNETS) : 0

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
    aws_route_table.private.*.id,
    var.SINGLE_NAT_GATEWAY ? 0 : count.index,
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.PUBLIC_SUBNETS) > 0 ? length(var.PUBLIC_SUBNETS) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}


