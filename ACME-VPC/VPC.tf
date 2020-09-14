// ACME VPC Resource for Module

provider "aws" {
  region = "eu-west-1"
    
}

###################
# RESOURCE
###################

## Transit Gateway deployed only in NATWORK Account . Total 3 TG need to be deployed in network account. and rest account transit gateway attachment will be done manually
/*
resource "aws_ec2_transit_gateway" "test-tgw" {
  description                     = "Transit Gateway creating for cross account network enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags                            = {
    Name               = "${var.Region}-${var.env}-TG-${var.service}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment DHCP Option set"
}
}

## DHCP to be deployed in all account except PROD & DEV SHARED Account. Because DNS1 AND DN2 ip will be available after deployment of AD in shared account.
resource "aws_vpc_dhcp_options" "dhcp" {
  domain_name          = "${var.domain_name}" #"acme.local"
  domain_name_servers  = ["${var.dns1}", "${var.dns2}"]
  #ntp_servers          = ["127.0.0.1"]

  tags = {
    Name               = "${var.Region}-${var.env}-DHCP-${var.service}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment DHCP Option set"
  }
}


resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.main_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp.id}"
}
*/


## VPC Flow Logs deployed of each account VPC

resource "aws_flow_log" "vpcflow" {
  iam_role_arn    = "${aws_iam_role.vpcflow.arn}"
  log_destination = "${aws_cloudwatch_log_group.vpcflow.arn}"
  traffic_type    = "ALL"
  vpc_id          = "${aws_vpc.main_vpc.id}"
}



resource "aws_cloudwatch_log_group" "vpcflow" {
  #name = "${var.Region}-${var.env}-VPC-${var.service}-${var.vpcrange}-vpcflowlog"
  retention_in_days = "90"
  name_prefix = "${var.Region}-${var.env}-VPC-${var.service}-${var.vpcrange}-CW"
  tags = {
    Name               = "${var.Region}-${var.env}-CW-${var.service}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment VPC ${var.vpcrange}"
}
}

resource "aws_iam_role" "vpcflow" {
  name = "${var.Region}-${var.env}-CW-IAM-${var.service}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

tags = {
    Name               = "${var.Region}-${var.env}-IAM-${var.service}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment VPC ${var.vpcrange}"
}
}

resource "aws_iam_role_policy" "vpcflow" {
  name = "${var.Region}-${var.env}-IAM-POLICY-${var.service}"
  role = "${aws_iam_role.vpcflow.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


## VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name               = "${var.Region}-${var.env}-VPC-${var.service}-${var.vpcrange}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment VPC ${var.vpcrange}"
  }
}


###################
# Public subnets  #
###################

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.main_vpc.id}"
  cidr_block        = "${element(var.public_subnet_cidr, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.public_subnet_cidr)}"

  tags = {
    Name               = "${var.Region}-${var.env}-SN-${var.service}-PB${element(var.az-tag, count.index)}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment Public Subnet"
  }

  #map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main_vpc.id}"
 #count  = "${length(var.public_subnet_cidr)}"


  tags = {
    Name               = "${var.Region}-${var.env}-RT-${var.service}-PB${element(var.az-tag, count.index)}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment Public Subnet RouteTable"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}


###################
# APP subnets #
###################

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.main_vpc.id}"
  cidr_block        = "${element(var.private_subnet_cidr, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.private_subnet_cidr)}"

  tags = {
    Name               = "${var.Region}-${var.env}-SN-${var.service}-AP${element(var.az-tag, count.index)}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment Application Subnet"
}
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  #count  = "${length(var.private_subnet_cidr)}"

  tags = {
    Name               = "${var.Region}-${var.env}-RT-${var.service}-AP${element(var.az-tag, count.index)}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment Application Subnet RouteTable"
  }
}
/*
resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  #route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
*/


##################################
# SERVICE-SUBNET
##################################

resource "aws_subnet" "service" {
  vpc_id            = "${aws_vpc.main_vpc.id}"
  cidr_block        = "${element(var.service_subnet_cidr, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.service_subnet_cidr)}"

  tags = {
    Name               = "${var.Region}-${var.env}-SN-${var.service}-SR${element(var.az-tag, count.index)}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment Service Subnet"
}
}

resource "aws_route_table" "service" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  #count  = "${length(var.private_subnet_cidr)}"

  tags = {
    Name               = "${var.Region}-${var.env}-RT-${var.service}-SR${element(var.az-tag, count.index)}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment Service Subnet RouteTable"
}
}
/*
resource "aws_route_table_association" "service" {
  count          = "${length(var.service_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.service.*.id, count.index)}"
  #route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.service.id}"
}
*/

###################
# DB subnets #
###################

resource "aws_subnet" "db" {
  vpc_id            = "${aws_vpc.main_vpc.id}"
  cidr_block        = "${element(var.db_subnet_cidr, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.db_subnet_cidr)}"

  tags = {
    Name               = "${var.Region}-${var.env}-SN-${var.service}-DB${element(var.az-tag, count.index)}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment Database Subnet"
}
}

resource "aws_route_table" "db" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  #count  = "${length(var.private_subnet_cidr)}"

  tags = {
    Name               = "${var.Region}-${var.env}-RT-${var.service}-DB${element(var.az-tag, count.index)}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment Database Subnet RouteTable"
  }
}
/*
resource "aws_route_table_association" "db" {
  count          = "${length(var.db_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.db.*.id, count.index)}"
  #route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.db.id}"
}
*/
#############################
# TRANSIT GATEWAY SUBNET
#############################

resource "aws_subnet" "tg" {
  vpc_id            = "${aws_vpc.main_vpc.id}"
  cidr_block        = "${element(var.tg_subnet_cidr, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.tg_subnet_cidr)}"

  tags = {
    Name               = "${var.Region}-${var.env}-SN-${var.service}-TG${element(var.az-tag, count.index)}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment Transit Gateway Subnet"
}
}

resource "aws_route_table" "tg" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  #count  = "${length(var.private_subnet_cidr)}"

  tags = {
    Name               = "${var.Region}-${var.env}-RT-${var.service}-TG${element(var.az-tag, count.index)}"
    Environment        = "${var.Environment}"
    Owner              = "${var.Owner}"
    CostCenter         = "${var.CostCenter}"
    Description        = "${var.Environment} Environment Transit Gateway RouteTable"
}
}

resource "aws_route_table_association" "tg" {
  count          = "${length(var.tg_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.tg.*.id, count.index)}"
  #route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.tg.id}"
}



resource "aws_route_table_association" "db" {
  count          = "${length(var.db_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.db.*.id, count.index)}"
  #route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.tg.id}"
}

resource "aws_route_table_association" "service" {
  count          = "${length(var.service_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.service.*.id, count.index)}"
  #route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.tg.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  #route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.tg.id}"
}


##### VARIABLE

######################
# TAGS

variable "Region" {
  default = "ME"
}

variable "env" {
  default = "P"
}

variable "service" {
  default = "NS"
}


variable "Environment" {
  default = "PROD"
}

variable "Owner" {
  default = "ACME"
}

variable "CostCenter" {
  default = "Billing"
}


###########################################
#VPC  Variables
############################################

variable "availability_zones" {
  default     = ["eu-west-1a", "eu-west-1b"]
  description = "The availability zones the we should create subnets in, launch instances in, and configure for ELB and ASG"
}

variable "az-tag" {
  default = ["01", "02"]
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "The range of IP addresses that we use in this VPC"
}

variable "public_subnet_cidr" {
  default     = ["10.0.9.0/24"]
  description = "CIDR blocks for public subnets. Number of entries must match 'availability_zones'."
}

variable "private_subnet_cidr" {
  default     = ["10.0.5.0/24"]
  description = "CIDR blocks for private subnets. Number of entries must match 'availability_zones'."
}

variable "service_subnet_cidr" {
  default     = ["10.0.6.0/24"]
  description = "CIDR blocks for public subnets. Number of entries must match 'availability_zones'."
}

variable "tg_subnet_cidr" {
  default     = ["10.0.2.0/24"]
  description = "CIDR blocks for public subnets. Number of entries must match 'availability_zones'."
}

variable "db_subnet_cidr" {
    default = ["10.0.1.0/24"]
    description = "CIDR blocks for public subnets. Number of entries must match 'availability_zones'."
}

# variable "domain_name" {
#   default = ""
# }

# variable "dns1" {
#   default = ""
# }

# variable "dns2" {
#   default = ""
# }

variable "vpcrange" {
    default = "000"
}


# output "vpc_id" {
#   value = "${aws_vpc.main_vpc.id}"
# }