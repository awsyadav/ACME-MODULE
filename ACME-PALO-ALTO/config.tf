## config.tf
data "aws_caller_identity" "current" {
}

provider "aws" {
  # assume_role {
  # #  role_arn = "arn:aws:iam::ACCOUNT_ID:role/CodeDeployDemo-EC2-Instance-Profile"
  #  role_arn = "arn:aws:iam::ACCOUNT_ID:role/CICD"
  #  session_name ="terraform"
  # }

  region = "me-south-1"
}


terraform {
  backend "s3" {
    bucket = "acme-tf-state-dev"
    key    = "palo-alto/palo-alto.tfstate"

    # Hosting in Middle East Bahrain Region
    region = "me-south-1"

    #dynamodb_table = "default-dev-terraform-state-locks"
    encrypt = true
  }
}

