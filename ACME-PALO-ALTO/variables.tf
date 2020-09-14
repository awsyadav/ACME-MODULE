variable "aws_region" {
  default = "eu-west-1"
}

# variable "vpc_id" {
#   default = ""
# }

variable "VPCName" {
  default = "ACME-VPC"
}

variable "MasterS3Bucket" {
  default = "masssterrrrs3buckeettttt"
}

variable "PublicCIDR_Block" {
  default = "10.0.1.0/24"
}

variable "StackName" {
  default = "PALOALTO"
}

variable "WebCIDR_Block" {
  default = "10.0.2.0/24"
}

variable "VPCCIDR" {
  default ="10.0.0.0/16"
}

variable "ServerKeyName" {
  default = "PALO-TEST"
}

variable "instance_type" {
  default = "m5.xlarge"
}

variable "ami" {
  default = "ami-0254c2d14ff95d3c9"
}

variable "WPWebInstance_ami" {
  default = "ami-0254c2d14ff95d3c9"
}
