// ACME EC2 Instance Resource for Module

provider "aws" {
  region = "eu-west-1"
    
}
resource "aws_instance" "ec2_instance" {
  ami           = "${var.ami-id}"
  subnet_id     =  "${var.subnet_id}"
  instance_type = "${var.instance_type}"
  #iam_instance_profile = "${var.iam_instance_profile}"
  vpc_security_group_ids = ["${var.security_group_ids}"]
  key_name               = "${var.key_name}"
  ebs_optimized          = "${var.ebs_optimized}"
  source_dest_check      = "${var.sdcheck}"
  #user_data              = "${var.user_data}"
  root_block_device  {
    volume_type           = "${lookup(var.root_block_device, "volume_type")}"
    volume_size           = "${lookup(var.root_block_device, "volume_size")}"
    delete_on_termination = "${lookup(var.root_block_device, "delete_on_termination")}"
  }

  tags = {
    Name               = "${var.regionname}-${var.env_short}-${var.servicename}-01"
    Environment        = "${var.environment}"
    Owner              = "${var.Owner}"
}

  lifecycle {
    ignore_changes = ["ami", "user_data", "subnet_id", "key_name", "ebs_optimized", "private_ip"]
  }
}


resource "aws_security_group" "sg" {
  name        = "${var.securitygroupname}"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name               = "${var.regionname}-${var.env_short}-SPLUNK-${var.servicename}-01"
    Environment        = "${var.environment}"
    Owner              = "${var.Owner}"
  }
}


resource "aws_security_group_rule" "rule1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg.id}"
  description       = "OutBound Rule"
}


resource "aws_security_group_rule" "rule2" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Change it after ward
  security_group_id = "${aws_security_group.sg.id}"
  description       = "ALLTCP-ec2-02"
}

## Variable

##### TAGS
variable "regionname" {
    default = "ME"
}

variable "environment" {
    default = "PROD"
}

variable "servicename" {
    default = "AP"
}

variable "env_short" {
    default = "P"
}

variable "Owner" {
    default = "ACME"
}

##### Resource Tags
variable "instance_type" {
    default = "t3.small"
    description = "EC2 instance type to use"
}
variable "ami-id" {
    default = "ami-07d9160fa81ccffb5"
}


variable "key_name" {
    default = "123"
}

variable "security_group_ids" {
    default = ["sg-00c10e5169cd09e51"]
}


variable "subnet_id" {
  default = "subnet-024ff0e71d8ae3aa8"
  }
  
  variable "sdcheck" {
      default = "true"
  }
  
  variable "root_block_device" {
  default = {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = true
  }
}

variable "ebs_optimized" {
    default = "true"
}

variable "securitygroupname" {
  default = "ACM-DEMO-SG-04"
}

variable "vpc_id" {
  default = "vpc-0eb8858d508dc6539"
}
# variable "user_data" {
#     default = ""
# }

# variable "iam_instance_profile" {
#     default = ""
# }


# output "inst_id" {
#   value = "${aws_instance.ec2_instance.id}"
# }

# output "inst_public" {
#   value = "${aws_instance.ec2_instance.public_ip}"
# }

# output "inst_publicdns" {
#   value = "${aws_instance.ec2_instance.public_dns}"
# }